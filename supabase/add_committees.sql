-- DSFH Residency Portal — Standing committees
-- Run in: Supabase → SQL Editor → New query. Safe to re-run.
--
-- Builds the Committees module on top of the EXISTING committee_memberships table
-- (created by add_canmeds_kpi_v2b.sql) rather than beside it. That table already
-- feeds the CanMEDS Collaborator KPI and the Manager gradient through the
-- committee_summary view, so a second membership table would silently fork the
-- KPI numbers. Everything here is additive: no column is dropped and the view is
-- left alone.
--
-- The one behavioural change is that committee_name stops being free text. Seven
-- fixed committees replace "type whatever you like", because the unique index is
-- on lower(committee_name) — so "Research Committee", "research" and "Research
-- Comm." were three different committees as far as the KPI was concerned.
--
-- Section 6 (backfill) is deliberately NOT run by this script. Read the audit in
-- section 5 first, then run section 6 by hand once the mapping looks right.


-- ─── 1. Committee catalogue ─────────────────────────────────────────────────
-- Committees themselves are year-agnostic; membership is what gets planned per
-- academic year. privilege_keys drives the automatic privilege grant in the app:
-- sitting on the Attendance Committee is what gives you the attendance buttons,
-- instead of the PD ticking boxes in the admin panel.

create table if not exists committees (
  id             smallint primary key,
  slug           text not null unique,
  name           text not null,
  description    text,
  color          text not null default '#c96a4a',
  sort_order     smallint not null,
  active         boolean not null default true,
  privilege_keys text[] not null default '{}'
);

insert into committees (id, slug, name, description, color, sort_order, privilege_keys) values
  (1,'attendance','Attendance Committee',
     'Morning meeting & academic day attendance auditing','#1a4a7a',1,
     array['edit_mm_attendance','edit_teach_attendance']),
  (2,'morning_meeting','Morning Meeting Committee',
     'Case selection, roster & session running','#c97a2a',2,
     array['edit_mm_schedule']),
  (3,'academic_activity','Academic Activity Committee',
     'Academic day curriculum & journal club','#A47A28',3,
     array['edit_teach_schedule']),
  (4,'well_being','Well-Being Committee',
     'Resident wellness, burnout & social activities','#2a7a5a',4,
     '{}'),
  (5,'qi','Quality Improvement Committee',
     'QI project oversight & patient-safety initiatives','#4a5e7a',5,
     '{}'),
  (6,'research','Research Committee',
     'Research mentorship, IRB guidance & publications','#6a4a7a',6,
     '{}'),
  (7,'morbidity_mortality','Morbidity & Mortality Committee',
     'M&M case review, presentation & follow-up','#b52040',7,
     '{}')
on conflict (id) do update
  set name           = excluded.name,
      description    = excluded.description,
      color          = excluded.color,
      sort_order     = excluded.sort_order,
      privilege_keys = excluded.privilege_keys;

alter table committees enable row level security;

drop policy if exists committees_select on committees;
create policy committees_select on committees
  for select to authenticated using (true);

drop policy if exists committees_write on committees;
create policy committees_write on committees for all to authenticated
  using (app_role() in ('pd','deputy_pd'))
  with check (app_role() in ('pd','deputy_pd'));


-- ─── 2. Roles on the existing membership table ──────────────────────────────
-- committee_id is nullable ON PURPOSE: legacy free-text rows keep working until
-- section 6 maps them. Everything the app writes from now on sets it.

alter table committee_memberships
  add column if not exists committee_id smallint references committees(id),
  add column if not exists role text not null default 'member';

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'committee_memberships_role_ck') then
    alter table committee_memberships
      add constraint committee_memberships_role_ck
      check (role in ('leader','co_leader','member'));
  end if;
end $$;

comment on column committee_memberships.role is
  'leader | co_leader | member. is_chair is derived from this by trigger and must not be written directly.';

-- One resident sits on a given committee once per year.
create unique index if not exists committee_memberships_res_year_cte_ux
  on committee_memberships (resident_id, academic_year, committee_id)
  where committee_id is not null;

-- Exactly one leader and one co-leader per committee per year.
create unique index if not exists committee_memberships_one_leader_ux
  on committee_memberships (committee_id, academic_year)
  where committee_id is not null and role = 'leader';

create unique index if not exists committee_memberships_one_coleader_ux
  on committee_memberships (committee_id, academic_year)
  where committee_id is not null and role = 'co_leader';

-- A resident may lead only ONE committee per year. Co-leading a second is fine,
-- which is why this index is on role='leader' alone rather than on both roles.
create unique index if not exists committee_memberships_one_lead_per_res_ux
  on committee_memberships (resident_id, academic_year)
  where committee_id is not null and role = 'leader';

create index if not exists committee_memberships_cte_year_ix
  on committee_memberships (committee_id, academic_year);


-- ─── 3. Eligibility guard ───────────────────────────────────────────────────
-- Enforced in the database, not just the UI, because the CanMEDS page can write
-- committee_memberships directly — a UI-only rule would leak through it.
--
-- is_chair is derived here. Co-leaders count as chairs for the CanMEDS Manager
-- gradient (confirmed with the PD), so the existing committee_summary view picks
-- them up without being touched.
--
-- The sync is BIDIRECTIONAL on purpose. The older CanMEDS page writes is_chair
-- directly and knows nothing about `role`; without the reverse leg, ticking
-- "Chairs this committee" there would be silently reset to false because the row
-- still carried the default role='member'.
--
-- The eligibility checks fire on INSERT, and on UPDATE only when the resident or
-- the role actually changes. Otherwise appointing a sitting committee member as
-- Chief would make every later edit of their existing rows fail — including the
-- edit needed to clean them up. Section 5 audits for that case instead.

create or replace function committee_membership_guard() returns trigger
language plpgsql as $$
declare
  v_level text;
  v_chief text;
  v_check boolean;
begin
  -- Reconcile role <-> is_chair before validating either of them.
  if tg_op = 'INSERT' then
    if new.is_chair and new.role = 'member' then
      new.role := 'leader';
    end if;
  elsif new.is_chair is distinct from old.is_chair and new.role = old.role then
    new.role := case when new.is_chair then 'leader' else 'member' end;
  end if;

  new.is_chair := (new.role in ('leader','co_leader'));

  v_check := (tg_op = 'INSERT')
             or new.resident_id is distinct from old.resident_id
             or new.role        is distinct from old.role;

  if v_check then
    select level, chief_role into v_level, v_chief
      from residents where id = new.resident_id;

    if v_chief is not null then
      raise exception 'The Chief and Co-Chief do not hold committee seats — their chief role is scored separately.'
        using errcode = 'check_violation';
    end if;

    if new.role = 'leader' and v_level = 'R1' then
      raise exception 'An R1 may co-lead or be a member, but may not lead a committee.'
        using errcode = 'check_violation';
    end if;
  end if;

  return new;
end $$;

drop trigger if exists committee_membership_guard_t on committee_memberships;
create trigger committee_membership_guard_t
  before insert or update on committee_memberships
  for each row execute function committee_membership_guard();


-- ─── 4. Faculty leads, meetings, achievements ───────────────────────────────
-- A committee may have one or more faculty leads.

create table if not exists committee_faculty (
  id            bigint generated always as identity primary key,
  committee_id  smallint not null references committees(id) on delete cascade,
  academic_year int not null,
  consultant_id bigint not null references consultants(id) on delete cascade,
  created_at    timestamptz not null default now(),
  unique (committee_id, academic_year, consultant_id)
);

-- Meetings mirror into calendar_events so they reach the month grid and the iCal
-- feed. calendar_event_id is the link back; deleting the meeting deletes the
-- mirrored event from the app side.
create table if not exists committee_meetings (
  id                uuid primary key default gen_random_uuid(),
  committee_id      smallint not null references committees(id) on delete cascade,
  academic_year     int not null,
  meeting_date      date not null,
  start_time        time,
  end_time          time,
  location          text,
  agenda            text,
  minutes           text,
  held              boolean not null default false,
  attended_ids      bigint[] not null default '{}',
  calendar_event_id uuid references calendar_events(id) on delete set null,
  created_by        uuid references auth.users(id) on delete set null,
  created_at        timestamptz not null default now(),
  constraint committee_meetings_times_ck check (
    (start_time is null and end_time is null)
    or (start_time is not null and end_time is not null and end_time > start_time)
  )
);

create index if not exists committee_meetings_cte_year_ix
  on committee_meetings (committee_id, academic_year);
create index if not exists committee_meetings_date_ix
  on committee_meetings (meeting_date);

create table if not exists committee_achievements (
  id            uuid primary key default gen_random_uuid(),
  committee_id  smallint not null references committees(id) on delete cascade,
  academic_year int not null,
  title         text not null,
  detail        text,
  achieved_on   date,
  created_by    uuid references auth.users(id) on delete set null,
  created_at    timestamptz not null default now()
);

create index if not exists committee_achievements_cte_year_ix
  on committee_achievements (committee_id, academic_year);

-- Who may write a committee's own content: PD/deputy/chief, or that committee's
-- leader / co-leader for the year in question.
create or replace function is_committee_lead(p_committee smallint, p_year int)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from committee_memberships m
     where m.committee_id  = p_committee
       and m.academic_year = p_year
       and m.role in ('leader','co_leader')
       and m.resident_id   = app_resident_id()
  );
$$;

alter table committee_faculty      enable row level security;
alter table committee_meetings     enable row level security;
alter table committee_achievements enable row level security;

drop policy if exists committee_faculty_select on committee_faculty;
create policy committee_faculty_select on committee_faculty
  for select to authenticated using (true);

drop policy if exists committee_faculty_write on committee_faculty;
create policy committee_faculty_write on committee_faculty for all to authenticated
  using (is_pd_or_chief()) with check (is_pd_or_chief());

drop policy if exists committee_meetings_select on committee_meetings;
create policy committee_meetings_select on committee_meetings
  for select to authenticated using (true);

drop policy if exists committee_meetings_write on committee_meetings;
create policy committee_meetings_write on committee_meetings for all to authenticated
  using (is_pd_or_chief() or is_committee_lead(committee_id, academic_year))
  with check (is_pd_or_chief() or is_committee_lead(committee_id, academic_year));

drop policy if exists committee_achievements_select on committee_achievements;
create policy committee_achievements_select on committee_achievements
  for select to authenticated using (true);

drop policy if exists committee_achievements_write on committee_achievements;
create policy committee_achievements_write on committee_achievements for all to authenticated
  using (is_pd_or_chief() or is_committee_lead(committee_id, academic_year))
  with check (is_pd_or_chief() or is_committee_lead(committee_id, academic_year));

-- Mirroring a meeting into calendar_events is what puts it on the members' month
-- grid and into the iCal feed. But cal_ev_all only lets is_pd_or_chief() write,
-- so a resident committee leader — the exact person meant to schedule these —
-- would be rejected. Tag the mirrored rows with the committee they came from and
-- let that committee's leads write those rows, and only those rows.
alter table calendar_events
  add column if not exists committee_id smallint references committees(id) on delete cascade;

create index if not exists cal_ev_committee_ix on calendar_events(committee_id);

drop policy if exists cal_ev_committee_lead on calendar_events;
create policy cal_ev_committee_lead on calendar_events for all to authenticated
  using      (committee_id is not null and is_committee_lead(committee_id, academic_year))
  with check (committee_id is not null and is_committee_lead(committee_id, academic_year));


-- ─── 5. AUDIT — run this and read it before section 6 ───────────────────────
-- What is currently sitting in the free-text column, and where each row would
-- land once mapped. Anything showing "-- NO MATCH --" needs a decision.

select
  m.committee_name,
  m.academic_year,
  count(*)                                              as rows,
  count(*) filter (where m.is_chair)                    as chairs,
  coalesce(c.name, '-- NO MATCH --')                    as would_map_to
from committee_memberships m
left join committees c on c.id = case
    when m.committee_name ~* 'attend'                 then 1
    when m.committee_name ~* 'morning'                then 2
    when m.committee_name ~* 'academ|teach|curricul'  then 3
    when m.committee_name ~* 'well|wellness|burnout'  then 4
    when m.committee_name ~* 'quality|^qi\M|\mqi\M'   then 5
    when m.committee_name ~* 'research'               then 6
    when m.committee_name ~* 'morbid|mortal|m ?& ?m'  then 7
  end
where m.committee_id is null
group by m.committee_name, m.academic_year, c.name
order by m.academic_year desc, rows desc;

-- Seats already held by the Chief / Co-Chief. The new rule says they hold none,
-- but existing rows are left in place rather than deleted behind your back —
-- clear them from the Committees page (or delete here) before section 6.
select m.id, r.name, r.chief_role, m.committee_name, m.academic_year, m.is_chair
from committee_memberships m
join residents r on r.id = m.resident_id
where r.chief_role is not null
order by r.chief_role, m.academic_year desc;

-- R1s recorded as chairs. These now violate the leader rule and will block any
-- later edit of the row until the role is corrected.
select m.id, r.name, r.level, m.committee_name, m.academic_year
from committee_memberships m
join residents r on r.id = m.resident_id
where m.is_chair and r.level = 'R1'
order by m.academic_year desc;


-- ─── 6. BACKFILL — do NOT run until the audit above looks right ─────────────
-- Commented out on purpose. Uncomment and run as a separate statement.
--
-- The backfill will FAIL, by design, if two residents were both recorded as
-- chair of what maps to the same committee in the same year — only one leader
-- per committee per year is allowed. Check for that first:
--
--   select committee_id, academic_year, count(*) from committee_memberships
--    where committee_id is not null and role = 'leader'
--    group by 1,2 having count(*) > 1;
--
-- Demote the extras to co_leader or member before re-running.
--
-- update committee_memberships m set
--   committee_id = case
--     when m.committee_name ~* 'attend'                 then 1
--     when m.committee_name ~* 'morning'                then 2
--     when m.committee_name ~* 'academ|teach|curricul'  then 3
--     when m.committee_name ~* 'well|wellness|burnout'  then 4
--     when m.committee_name ~* 'quality|^qi\M|\mqi\M'   then 5
--     when m.committee_name ~* 'research'               then 6
--     when m.committee_name ~* 'morbid|mortal|m ?& ?m'  then 7
--   end,
--   role = case when m.is_chair then 'leader' else 'member' end
-- where m.committee_id is null;
--
-- Rows the regex could not place keep committee_id = null and stay visible in
-- the audit. Map those by hand:
--   update committee_memberships set committee_id = 5, role = 'member' where id = 123;


-- ─── 7. Verify ──────────────────────────────────────────────────────────────
select id, slug, name, privilege_keys from committees order by sort_order;

select column_name, data_type, is_nullable
from information_schema.columns
where table_name = 'committee_memberships'
order by ordinal_position;

select tablename, policyname, cmd from pg_policies
where tablename in ('committees','committee_faculty','committee_meetings','committee_achievements')
order by tablename, policyname;

select indexname from pg_indexes
where tablename = 'committee_memberships'
order by indexname;
-- Expect the four new *_ux indexes plus the original res_year_name_ux.
