-- DSFH Residency Portal — Research module (15 Nov 2026)
--
-- The Research Committee opens a project, puts residents on it and tracks its steps. One row per
-- PROJECT here (research_studies), with its team and its steps beside it. The Scholar KPI keeps
-- reading research_projects (one row per resident), and this file keeps those rows in step:
--
--   * Being put on a project writes NOTHING to research_projects. It is not KPI credit.
--   * When a confirmer (the Program Director, plus anyone named in portal_settings 'research')
--     confirms IRB approval, submission or publication, every team member marked as an author gets
--     or updates a research_projects row at that stage. Undoing the confirmation removes it again.
--
-- Who sees a project: its team, its supervising consultant, the mentor of a team member, the
-- Research Committee's leader / co-leader / faculty lead for the current year, the PD, the Deputy,
-- DIO, CEO, the Chief Resident and the Co-Chief (who see every project but do not run them, unless
-- they also hold a committee seat). Nobody else.
--
-- Also here: the answers to the Research Committee's Google Form (research_interest), which the
-- research-interest edge function writes, and the notifications sent when a step is reported or
-- confirmed and when a resident is put on a project.
--
-- Run once in the Supabase SQL Editor. Safe to run again. The last statements only report.

-- ─── 1. Tables ───────────────────────────────────────────────────────────────

create table if not exists research_studies (
  id                       bigint generated always as identity primary key,
  title                    text not null,
  study_type               text,
  specialty                text,
  supervisor_consultant_id bigint references consultants(id) on delete set null,
  supervisor_name          text,
  started_year             int not null,           -- cycle start year, 2026 = AY 2026-27
  status                   text not null default 'active' check (status in ('active','closed')),
  irb_number               text,
  journal                  text,
  citation                 text,
  evidence_url             text,
  now_note                 text,                   -- the "Now" line: what the team is doing this week
  created_by               uuid references profiles(id),
  created_at               timestamptz not null default now(),
  updated_at               timestamptz not null default now()
);

create table if not exists research_study_members (
  id          bigint generated always as identity primary key,
  study_id    bigint not null references research_studies(id) on delete cascade,
  resident_id bigint not null references residents(id) on delete cascade,
  role        text not null default 'Member',      -- Lead, Data, Analysis, Writing ...
  is_lead     boolean not null default false,
  is_author   boolean not null default true,       -- credited when a KPI step is confirmed
  added_at    timestamptz not null default now(),
  unique (study_id, resident_id)
);

-- One row per step that has something to say. A step with no row is "not yet".
--   reported   = the team says it is done; waits for a confirmer (KPI steps only)
--   done       = done; for irb / sub / pub this means CONFIRMED
--   not_needed = this study skips the step (a case report has no data collection)
create table if not exists research_study_steps (
  id           bigint generated always as identity primary key,
  study_id     bigint not null references research_studies(id) on delete cascade,
  step_key     text not null,
  state        text not null check (state in ('reported','done','not_needed')),
  done_on      date,
  note         text,
  evidence_url text,
  reported_by  uuid references profiles(id),
  reported_at  timestamptz,
  confirmed_by uuid references profiles(id),
  confirmed_at timestamptz,
  updated_at   timestamptz not null default now(),
  unique (study_id, step_key)
);

create index if not exists research_study_members_res_ix  on research_study_members (resident_id);
create index if not exists research_study_steps_study_ix  on research_study_steps (study_id);

-- The link back from the KPI record. study_adopted marks a row that existed BEFORE the project
-- claimed it (same resident, same title): undoing a confirmation unlinks such a row, never deletes it.
alter table research_projects
  add column if not exists study_id      bigint references research_studies(id) on delete set null,
  add column if not exists study_adopted boolean not null default false;

create index if not exists research_projects_study_ix on research_projects (study_id);

-- ─── 2. Who may do what ──────────────────────────────────────────────────────

create or replace function research_current_ay() returns int
language sql stable security definer set search_path = public as $$
  select coalesce((select max(ay) from academic_years where start_date <= current_date),
                  extract(year from current_date)::int - 1);
$$;

-- Runs the committee's projects: PD, Deputy, and this year's Research Committee leader,
-- co-leader and faculty lead.
create or replace function is_research_manager() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce(app_role() in ('pd','deputy_pd'), false)
      or exists (select 1 from committee_memberships m join committees c on c.id = m.committee_id
                  where c.slug = 'research' and m.academic_year = research_current_ay()
                    and m.role in ('leader','co_leader') and m.resident_id = app_resident_id())
      or exists (select 1 from committee_faculty f join committees c on c.id = f.committee_id
                  where c.slug = 'research' and f.academic_year = research_current_ay()
                    and f.consultant_id = app_consultant_id());
$$;

-- Confirms the three steps that move the KPI. The PD always; others are added in the portal
-- (Research > Settings), stored as profile ids in portal_settings key 'research'.
create or replace function can_confirm_research() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce(app_role() = 'pd', false)
      or exists (select 1 from portal_settings s
                  where s.key = 'research' and (s.value -> 'confirmers') ? (auth.uid())::text);
$$;

create or replace function research_is_member(p_study bigint) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from research_study_members m
                  where m.study_id = p_study and m.resident_id = app_resident_id());
$$;

-- Sees every project without running them: the leads and confirmers, DIO, CEO, the Chief Resident
-- and the Co-Chief (PD, 15 Nov 2026).
create or replace function research_sees_all() returns boolean
language sql stable security definer set search_path = public as $$
  select is_research_manager() or can_confirm_research()
      or coalesce(app_role() in ('dio','ceo','chief'), false)
      or exists (select 1 from residents r where r.id = app_resident_id() and r.chief_role is not null);
$$;

create or replace function research_can_see(p_study bigint) returns boolean
language sql stable security definer set search_path = public as $$
  select research_sees_all()
      or research_is_member(p_study)
      or exists (select 1 from research_studies s
                  where s.id = p_study and s.supervisor_consultant_id = app_consultant_id())
      or (app_role() = 'consultant' and exists (
            select 1 from research_study_members m join residents r on r.id = m.resident_id
             where m.study_id = p_study and r.mentor_id = app_consultant_id()));
$$;

alter table research_studies       enable row level security;
alter table research_study_members enable row level security;
alter table research_study_steps   enable row level security;

drop policy if exists research_studies_select on research_studies;
create policy research_studies_select on research_studies for select to authenticated
  using (research_can_see(id));
drop policy if exists research_studies_insert on research_studies;
create policy research_studies_insert on research_studies for insert to authenticated
  with check (is_research_manager());
-- A team member may update the row, but the guard trigger below lets them change the Now line only.
drop policy if exists research_studies_update on research_studies;
create policy research_studies_update on research_studies for update to authenticated
  using (is_research_manager() or research_is_member(id))
  with check (is_research_manager() or research_is_member(id));
drop policy if exists research_studies_delete on research_studies;
create policy research_studies_delete on research_studies for delete to authenticated
  using (is_research_manager());

drop policy if exists research_study_members_select on research_study_members;
create policy research_study_members_select on research_study_members for select to authenticated
  using (research_can_see(study_id));
drop policy if exists research_study_members_write on research_study_members;
create policy research_study_members_write on research_study_members for all to authenticated
  using (is_research_manager()) with check (is_research_manager());

-- Steps. The team and the committee leads may report any step and mark the ordinary ones done.
-- Only a confirmer may write, change or remove a DONE irb / sub / pub row.
drop policy if exists research_study_steps_select on research_study_steps;
create policy research_study_steps_select on research_study_steps for select to authenticated
  using (research_can_see(study_id));
drop policy if exists research_study_steps_insert on research_study_steps;
create policy research_study_steps_insert on research_study_steps for insert to authenticated
  with check (
    can_confirm_research()
    or ((research_is_member(study_id) or is_research_manager())
        and not (step_key in ('irb','sub','pub') and state = 'done')));
drop policy if exists research_study_steps_update on research_study_steps;
create policy research_study_steps_update on research_study_steps for update to authenticated
  using (
    can_confirm_research()
    or ((research_is_member(study_id) or is_research_manager())
        and not (step_key in ('irb','sub','pub') and state = 'done')))
  with check (
    can_confirm_research()
    or ((research_is_member(study_id) or is_research_manager())
        and not (step_key in ('irb','sub','pub') and state = 'done')));
drop policy if exists research_study_steps_delete on research_study_steps;
create policy research_study_steps_delete on research_study_steps for delete to authenticated
  using (
    can_confirm_research()
    or ((research_is_member(study_id) or is_research_manager())
        and not (step_key in ('irb','sub','pub') and state = 'done')));

-- ─── 3. Guards ───────────────────────────────────────────────────────────────

-- A team member who is not a committee lead may change the Now line and nothing else.
create or replace function research_study_guard() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is not null and not is_research_manager() then
    if (to_jsonb(new) - 'now_note' - 'updated_at') is distinct from (to_jsonb(old) - 'now_note' - 'updated_at') then
      raise exception 'Only the Research Committee leads can change a project''s details.';
    end if;
  end if;
  return new;
end $$;

drop trigger if exists research_study_guard_trg on research_studies;
create trigger research_study_guard_trg before update on research_studies
  for each row execute function research_study_guard();

-- Stamp who confirmed, and give a confirmed KPI step a date (research_projects needs one).
create or replace function research_step_stamp() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  new.updated_at := now();
  if new.state = 'reported' and (tg_op = 'INSERT' or old.state is distinct from 'reported') then
    new.reported_by := auth.uid(); new.reported_at := now();
  end if;
  if new.state = 'done' and new.step_key in ('irb','sub','pub') then
    new.done_on := coalesce(new.done_on, current_date);
    if tg_op = 'INSERT' or old.state is distinct from 'done' then
      new.confirmed_by := auth.uid(); new.confirmed_at := now();
    end if;
  end if;
  return new;
end $$;

drop trigger if exists research_step_stamp_trg on research_study_steps;
create trigger research_step_stamp_trg before insert or update on research_study_steps
  for each row execute function research_step_stamp();

-- ─── 4. Keep the KPI record in step ──────────────────────────────────────────

create or replace function research_sync_study(p_study bigint) returns void
language plpgsql security definer set search_path = public as $$
declare
  s        research_studies%rowtype;
  v_irb    date; v_sub date; v_pub date;
  v_status text;
  m        record;
  v_row    bigint;
begin
  select * into s from research_studies where id = p_study;
  if not found then return; end if;

  select max(done_on) filter (where step_key = 'irb'),
         max(done_on) filter (where step_key = 'sub'),
         max(done_on) filter (where step_key = 'pub')
    into v_irb, v_sub, v_pub
    from research_study_steps where study_id = p_study and state = 'done';

  v_status := case when v_pub is not null then 'published'
                   when v_sub is not null then 'submitted'
                   when v_irb is not null then 'irb_approved' end;

  -- Nothing confirmed (any more): the project gives no KPI record.
  if v_status is null then
    delete from research_projects where study_id = p_study and not study_adopted;
    update research_projects set study_id = null, study_adopted = false where study_id = p_study;
    return;
  end if;

  for m in select * from research_study_members where study_id = p_study and is_author loop
    select id into v_row from research_projects
     where study_id = p_study and resident_id = m.resident_id limit 1;
    if v_row is null then
      -- The resident already has this paper on file under the same title: claim it, do not duplicate.
      select id into v_row from research_projects
       where study_id is null and resident_id = m.resident_id and lower(title) = lower(s.title)
       order by id limit 1;
      if v_row is not null then
        update research_projects set study_id = p_study, study_adopted = true where id = v_row;
      end if;
    end if;
    if v_row is null then
      insert into research_projects (resident_id, title, started_year, status,
                                     irb_number, irb_approved_at, submitted_at, published_at,
                                     journal, citation, role, evidence_url, study_id, notes)
      values (m.resident_id, s.title, s.started_year, v_status,
              s.irb_number, v_irb, v_sub, v_pub,
              s.journal, s.citation, m.role, s.evidence_url, p_study,
              'From the Research module');
    else
      update research_projects
         set title = s.title, status = v_status,
             irb_number      = coalesce(s.irb_number, irb_number),
             irb_approved_at = coalesce(v_irb, irb_approved_at),
             submitted_at    = coalesce(v_sub, submitted_at),
             published_at    = coalesce(v_pub, published_at),
             journal         = coalesce(s.journal, journal),
             citation        = coalesce(s.citation, citation),
             evidence_url    = coalesce(s.evidence_url, evidence_url),
             role            = m.role,
             updated_at      = now()
       where id = v_row;
    end if;
    v_row := null;
  end loop;

  -- Someone taken off the team, or no longer an author.
  delete from research_projects p
   where p.study_id = p_study and not p.study_adopted
     and not exists (select 1 from research_study_members x
                      where x.study_id = p_study and x.resident_id = p.resident_id and x.is_author);
  update research_projects p set study_id = null, study_adopted = false
   where p.study_id = p_study and p.study_adopted
     and not exists (select 1 from research_study_members x
                      where x.study_id = p_study and x.resident_id = p.resident_id and x.is_author);
end $$;

create or replace function research_sync_trg() returns trigger
language plpgsql security definer set search_path = public as $$
declare v_study bigint;
begin
  if tg_table_name = 'research_studies' then
    v_study := new.id;
  else
    if tg_op = 'DELETE' then v_study := old.study_id; else v_study := new.study_id; end if;
    -- Every change to the team or the steps counts as an update of the project.
    update research_studies set updated_at = now() where id = v_study;
  end if;
  perform research_sync_study(v_study);
  return null;
end $$;

drop trigger if exists research_steps_sync_trg on research_study_steps;
create trigger research_steps_sync_trg after insert or update or delete on research_study_steps
  for each row execute function research_sync_trg();

drop trigger if exists research_members_sync_trg on research_study_members;
create trigger research_members_sync_trg after insert or update or delete on research_study_members
  for each row execute function research_sync_trg();

drop trigger if exists research_studies_sync_trg on research_studies;
create trigger research_studies_sync_trg
  after update of title, started_year, irb_number, journal, citation, evidence_url on research_studies
  for each row execute function research_sync_trg();

-- ─── 5. Notifications ────────────────────────────────────────────────────────
-- Sent by the database so they do not depend on who is signed in. A failure here must never
-- block the step or the assignment itself, hence the exception handlers.

create or replace function research_step_notify() returns trigger
language plpgsql security definer set search_path = public as $$
declare v_title text; v_what text;
begin
  if new.step_key not in ('irb','sub','pub') then return null; end if;
  if tg_op = 'UPDATE' and old.state is not distinct from new.state then return null; end if;
  begin
    select title into v_title from research_studies where id = new.study_id;
    v_what := case new.step_key when 'irb' then 'IRB approval' when 'sub' then 'Submission' else 'Publication' end;
    if new.state = 'reported' then
      insert into notifications (profile_id, type, message, link_mod, read)
      select p.id, 'info', 'Research: ' || v_what || ' reported for "' || coalesce(v_title, 'a project') || '". It waits for your confirmation.', 'research', false
        from profiles p
       where (p.role = 'pd' or exists (select 1 from portal_settings s
                                        where s.key = 'research' and (s.value -> 'confirmers') ? (p.id)::text))
         and p.id is distinct from auth.uid();
    elsif new.state = 'done' then
      insert into notifications (profile_id, type, message, link_mod, read)
      select p.id, 'info', 'Research: ' || v_what || ' confirmed for "' || coalesce(v_title, 'your project') || '". It now counts toward your Scholar KPI.', 'research', false
        from research_study_members m join profiles p on p.resident_id = m.resident_id
       where m.study_id = new.study_id and m.is_author;
    end if;
  exception when others then null;
  end;
  return null;
end $$;

drop trigger if exists research_step_notify_trg on research_study_steps;
create trigger research_step_notify_trg after insert or update on research_study_steps
  for each row execute function research_step_notify();

create or replace function research_member_notify() returns trigger
language plpgsql security definer set search_path = public as $$
declare v_title text;
begin
  begin
    select title into v_title from research_studies where id = new.study_id;
    insert into notifications (profile_id, type, message, link_mod, read)
    select p.id, 'info', 'Research: you were added to "' || coalesce(v_title, 'a project') || '" as ' || new.role || '.', 'research', false
      from profiles p where p.resident_id = new.resident_id and p.id is distinct from auth.uid();
  exception when others then null;
  end;
  return null;
end $$;

drop trigger if exists research_member_notify_trg on research_study_members;
create trigger research_member_notify_trg after insert on research_study_members
  for each row execute function research_member_notify();

-- ─── 6. Answers to the Research Committee's Google Form ──────────────────────
-- Written only by the research-interest edge function (service role). One row per form response;
-- sending a response again replaces it. resident_id is filled when the typed name matches exactly
-- one resident, otherwise a committee lead links it by hand in the portal (matched_by = 'manual',
-- which a resend never overwrites). Phone numbers and e-mail addresses live here, so only the
-- committee leads, the confirmers and the resident who answered can read a row.

create table if not exists research_interest (
  id           bigint generated always as identity primary key,
  response_key text not null unique,
  submitted_at timestamptz not null default now(),
  full_name    text,
  resident_ref text,
  level_text   text,
  phone        text,
  gmail        text,
  whatsapp_ok  text,
  answers      jsonb not null default '{}'::jsonb,
  resident_id  bigint references residents(id) on delete set null,
  matched_by   text check (matched_by in ('name','manual')),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create index if not exists research_interest_res_ix on research_interest (resident_id);

alter table research_interest enable row level security;

drop policy if exists research_interest_select on research_interest;
create policy research_interest_select on research_interest for select to authenticated
  using (is_research_manager() or can_confirm_research() or resident_id = app_resident_id());
drop policy if exists research_interest_update on research_interest;
create policy research_interest_update on research_interest for update to authenticated
  using (is_research_manager()) with check (is_research_manager());
drop policy if exists research_interest_delete on research_interest;
create policy research_interest_delete on research_interest for delete to authenticated
  using (is_research_manager());

-- ─── 7. Report ───────────────────────────────────────────────────────────────

select 'research_studies' as object, count(*) as n from research_studies
union all select 'research_study_members', count(*) from research_study_members
union all select 'research_study_steps',   count(*) from research_study_steps
union all select 'research_interest',      count(*) from research_interest;

select tablename, policyname, cmd from pg_policies
 where schemaname = 'public' and (tablename like 'research_stud%' or tablename = 'research_interest')
 order by tablename, policyname;

-- Who holds the Research Committee seats this year (these people see and run every project).
select m.academic_year, m.role, r.name
  from committee_memberships m
  join committees c on c.id = m.committee_id
  join residents r on r.id = m.resident_id
 where c.slug = 'research' and m.role in ('leader','co_leader')
 order by m.academic_year desc, m.role;
