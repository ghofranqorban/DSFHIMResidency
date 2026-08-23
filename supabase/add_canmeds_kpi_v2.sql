-- ═══════════════════════════════════════════════════════════════════════════
-- KPI v2 — CanMEDS threshold/gradient model
-- Run once in: Supabase → SQL Editor → New query.  Safe to re-run.
--
-- PREREQUISITES, or section 2 will fail with "relation kpi_quarterly does not
-- exist": add_kpi_quarterly_proposals.sql and add_kpi_scores.sql must already
-- have been run, and the helper functions app_role() / app_consultant_id() /
-- is_pd_or_chief() must exist (schema.sql + fix_attendance_rls_and_deputy_pd.sql).
-- ═══════════════════════════════════════════════════════════════════════════
--
-- Supports the model agreed 20 Aug 2026: a binary KPI layer ("did they meet the
-- standard?") plus an UNAGGREGATED Performance gradient ("how well?"), organised
-- by the seven CanMEDS 2015 roles.
--
-- Three things the current schema cannot express, and this migration adds:
--
--   1. SCHOLAR — kpi_scores.bonus_published is a boolean. It cannot tell 1
--      publication from 3, so it can serve the KPI but not the gradient. It also
--      cannot hold the IRB ramp (registered → IRB approved → published), which is
--      the whole point of not failing every R1 on a once-per-training metric.
--      → new table `research_projects`, one row per project.
--
--   2. COMMUNICATOR — no home for the quarterly mentor rating.
--      → new column `kpi_quarterly.communicator_rating`.
--
--   3. HEALTH ADVOCATE — awareness campaigns are not recorded anywhere, and
--      kpi_scores.volunteering is again a boolean that cannot count.
--      → new table `advocacy_activities`.
--
-- NOTHING IS DROPPED. kpi_scores.bonus_published / bonus_oral / bonus_poster /
-- volunteering all stay exactly as they are, because the live HTML still reads
-- them. Cut them over in the app first, then retire them in a separate migration.
--
-- ─── TWO THINGS TO DECIDE BEFORE THIS DRIVES ANY SCORE ──────────────────────
--
--   (a) AWARENESS CAMPAIGN IS CURRENTLY OPT-IN ("if they are interested").
--       A KPI must be clearable by every resident through their own effort. If
--       taking part stays optional, a Health Advocate KPI would fail residents
--       for declining something they were never required to do. Either make one
--       campaign a programme requirement, or keep this as Performance only.
--       This migration only stores the data; it takes no position.
--
--   (b) THE R2 RAMP STATE IS UNDEFINED. The agreed ramp names R1 ("not yet due")
--       and R3/R4 ("not met") but never says what an R2 with nothing on file is.
--       The expectation ramp says R2 = "project identified", so `research_ramp`
--       below reports R2-with-nothing as 'at_risk'. THAT IS MY ASSUMPTION, not
--       your decision — change it in the view if you meant otherwise.
--
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── 1. SCHOLAR: research projects ──────────────────────────────────────────
-- One row per project per resident. Publication count = rows with status
-- 'published'; the IRB ramp reads irb_approved_at / status.

create table if not exists research_projects (
  id               bigint generated always as identity primary key,
  resident_id      bigint not null references residents(id) on delete cascade,
  title            text not null,
  -- Academic year (portal numbering: cycle start year, e.g. 2025 = 2025-26) in
  -- which the project was registered. A project spans years, so this is the
  -- START year -- for "published this year" use published_at, not started_year.
  started_year     int not null,
  status           text not null default 'registered'
                     check (status in ('registered','irb_approved','submitted','published','abandoned')),
  irb_number       text,
  irb_approved_at  date,
  submitted_at     date,
  published_at     date,
  journal          text,
  citation         text,
  -- Free text: 'principal investigator', 'co-investigator', 'co-author'...
  role             text,
  evidence_url     text,
  notes            text,
  updated_by       uuid references profiles(id),
  updated_at       timestamptz not null default now(),
  created_at       timestamptz not null default now()
);

-- Keep status and the dates from contradicting each other. Without this you can
-- have status='published' with no published_at, and the ramp silently misreads.
alter table research_projects drop constraint if exists research_projects_status_dates_ck;
alter table research_projects add constraint research_projects_status_dates_ck check (
      (status <> 'published'     or published_at    is not null)
  and (status <> 'submitted'     or submitted_at    is not null)
  and (status <> 'irb_approved'  or irb_approved_at is not null)
);

-- One resident cannot register the same project title twice in the same year.
-- Deliberately NOT unique on (resident_id) alone: 3 publications is the whole
-- point of the gradient.
create unique index if not exists research_projects_res_year_title_ux
  on research_projects (resident_id, started_year, lower(title));

create index if not exists research_projects_resident_ix on research_projects (resident_id);
create index if not exists research_projects_status_ix   on research_projects (status);

comment on table  research_projects is
  'One row per research project per resident. Feeds the CanMEDS Scholar KPI (>=1 published per training) and its Performance gradient (publication count).';
comment on column research_projects.started_year is
  'Academic year the project was registered, portal numbering (cycle start year). Not the publication year.';

-- CO-AUTHORSHIP: if three residents share one project, enter three rows. That
-- is intentional -- each resident needs their own KPI state, and a join table
-- would be a heavier change than this model needs. The cost is that the
-- PROGRAMME-level count of distinct projects is not simply count(*); use
-- count(distinct lower(title)) if you ever report projects rather than residents.


-- ─── 2. COMMUNICATOR: quarterly mentor rating ───────────────────────────────
-- FORMATIVE ONLY. This is a check-in flag, NOT a KPI and NOT a score input.
-- Mumaris holds the authoritative ITER; where the two disagree, Mumaris wins.
-- The screen showing this MUST say so. A subjective, unanchored rating that
-- gates a compliance metric is what makes a KPI layer unauditable.

alter table kpi_quarterly
  add column if not exists communicator_rating text,
  add column if not exists communicator_note   text,
  add column if not exists communicator_set_at timestamptz;

alter table kpi_quarterly drop constraint if exists kpi_quarterly_communicator_rating_ck;
alter table kpi_quarterly add constraint kpi_quarterly_communicator_rating_ck
  check (communicator_rating is null
         or communicator_rating in ('achieved','partially_met','not_met'));

comment on column kpi_quarterly.communicator_rating is
  'Formative mentor check-in, quarterly. NOT authoritative -- Mumaris ITER is the source of truth. Anchors: achieved = explains plans in language the patient/family understands and checks back, hand-overs complete; partially_met = adequate routinely but needs prompting in difficult conversations or hand-over gaps noticed; not_met = repeated unclear, absent or late communication with patients, families or team. DRAFT ANCHORS -- confirm wording with the PD before they go on screen.';


-- ─── 3. HEALTH ADVOCATE: awareness campaigns and volunteering ───────────────
-- A table rather than a boolean, so campaigns can be COUNTED for the gradient
-- and each one carries its own evidence.

create table if not exists advocacy_activities (
  id             bigint generated always as identity primary key,
  resident_id    bigint not null references residents(id) on delete cascade,
  academic_year  int not null,
  kind           text not null check (kind in ('awareness_campaign','volunteering')),
  title          text not null,
  activity_date  date,
  -- 'organiser', 'presenter', 'participant'... note that ORGANISER/LEAD roles are
  -- scarce, so they belong to the gradient, never to the binary threshold.
  role           text,
  hours          numeric(5,1),
  evidence_url   text,
  notes          text,
  updated_by     uuid references profiles(id),
  updated_at     timestamptz not null default now(),
  created_at     timestamptz not null default now()
);

create unique index if not exists advocacy_activities_res_year_kind_title_ux
  on advocacy_activities (resident_id, academic_year, kind, lower(title));

create index if not exists advocacy_activities_resident_ix on advocacy_activities (resident_id);

comment on table advocacy_activities is
  'Awareness campaigns (CanMEDS Health Advocate) and volunteering. One row per activity so they can be counted; kpi_scores.volunteering is a boolean and cannot.';


-- ─── 4. RLS ─────────────────────────────────────────────────────────────────
-- READ = every authenticated user. This is deliberate and it is NOT laziness:
-- the programme-level KPI (">50% of residents published") and the Performance
-- Report leaderboard are computed CLIENT-SIDE over every resident. If a resident
-- session could only read its own rows, the denominator would silently collapse
-- and each user would see a different programme percentage. That exact bug
-- already happened on kpi_scores -- see fix_kpi_scores_read_rls.sql.
--
-- WRITE = PD / chief / deputy_pd (via is_pd_or_chief()) or the resident's own
-- assigned mentor. Residents do NOT write here; they route through the existing
-- kpi_proposals table, which the PD approves. Adding a second, parallel
-- self-entry path is a design decision that has not been made -- if you do want
-- residents to register their own projects, add an INSERT-only policy rather
-- than widening these.

alter table research_projects    enable row level security;
alter table advocacy_activities  enable row level security;

drop policy if exists research_projects_select on research_projects;
create policy research_projects_select on research_projects
  for select to authenticated using (true);

drop policy if exists research_projects_write on research_projects;
create policy research_projects_write on research_projects for all to authenticated
  using (
    is_pd_or_chief()
    or (app_role() = 'consultant'
        and resident_id in (select id from residents where mentor_id = app_consultant_id()))
  )
  with check (
    is_pd_or_chief()
    or (app_role() = 'consultant'
        and resident_id in (select id from residents where mentor_id = app_consultant_id()))
  );

drop policy if exists advocacy_activities_select on advocacy_activities;
create policy advocacy_activities_select on advocacy_activities
  for select to authenticated using (true);

drop policy if exists advocacy_activities_write on advocacy_activities;
create policy advocacy_activities_write on advocacy_activities for all to authenticated
  using (
    is_pd_or_chief()
    or (app_role() = 'consultant'
        and resident_id in (select id from residents where mentor_id = app_consultant_id()))
  )
  with check (
    is_pd_or_chief()
    or (app_role() = 'consultant'
        and resident_id in (select id from residents where mentor_id = app_consultant_id()))
  );


-- ─── 5. Scholar ramp view ───────────────────────────────────────────────────
-- security_invoker = the caller's RLS applies, so this view cannot leak rows a
-- user could not already select directly.
--
-- NEEDS POSTGRES 15+. If this line errors with "unrecognized parameter
-- security_invoker", your project is on PG14: delete the `with (...)` clause and
-- the view still works, but it then runs as its OWNER and bypasses RLS. Since
-- section 4 makes these tables readable by every authenticated user anyway, that
-- leaks nothing today -- but it would if you ever narrow those SELECT policies.

drop view if exists research_ramp;
create view research_ramp with (security_invoker = true) as
select
  r.id                                          as resident_id,
  r.name,
  r.level,
  count(p.id) filter (where p.status = 'published')                    as published_count,
  count(p.id) filter (where p.status <> 'abandoned')                   as active_projects,
  bool_or(p.irb_approved_at is not null)                               as has_irb,
  case
    when count(p.id) filter (where p.status = 'published') > 0  then 'met'
    when bool_or(p.irb_approved_at is not null)                 then 'on_track'
    when count(p.id) filter (where p.status <> 'abandoned') > 0 then 'at_risk'
    when r.level = 'R1'                                         then 'not_yet_due'
    -- R2 with nothing on file: ASSUMPTION, see the header note (b).
    when r.level = 'R2'                                         then 'at_risk'
    else 'not_met'
  end as ramp_state
from residents r
left join research_projects p on p.resident_id = r.id
where r.active and r.archived_at is null
group by r.id, r.name, r.level;

comment on view research_ramp is
  'Per-resident CanMEDS Scholar ramp state. R2-with-nothing is reported as at_risk -- an assumption, not a confirmed rule (see add_canmeds_kpi_v2.sql header).';


-- ─── 6. Optional backfill ───────────────────────────────────────────────────
-- Commented out on purpose: RUN IT ONCE OR NOT AT ALL, and read it first.
-- It seeds research_projects from the old boolean so nobody's existing
-- publication disappears the day the app switches over. The unique index makes
-- a second run a no-op, but the placeholder title is obviously a placeholder --
-- the PD will need to fill in real titles afterwards.
--
-- insert into research_projects (resident_id, title, started_year, status, published_at, notes)
-- select k.resident_id,
--        'Migrated from kpi_scores (title unknown)',
--        k.academic_year,
--        'published',
--        make_date(k.academic_year, 7, 1),   -- placeholder: 1 July of that year
--        'Auto-migrated from kpi_scores.bonus_published on ' || current_date || '. Replace title and date.'
-- from kpi_scores k
-- where k.bonus_published
-- on conflict do nothing;
--
-- insert into advocacy_activities (resident_id, academic_year, kind, title, notes)
-- select k.resident_id, k.academic_year, 'volunteering',
--        'Migrated from kpi_scores (title unknown)',
--        'Auto-migrated from kpi_scores.volunteering on ' || current_date || '.'
-- from kpi_scores k
-- where k.volunteering
-- on conflict do nothing;


-- ─── 7. Verify ──────────────────────────────────────────────────────────────
select 'research_projects'   as object, count(*) as n from research_projects
union all
select 'advocacy_activities', count(*) from advocacy_activities
union all
select 'kpi_quarterly.communicator_rating', count(*)
  from information_schema.columns
  where table_name = 'kpi_quarterly' and column_name = 'communicator_rating'
union all
select 'research_ramp view', count(*) from research_ramp;


-- ═══════════════════════════════════════════════════════════════════════════
-- ROLLBACK (paste separately if you need to undo this)
--
--   drop view if exists research_ramp;
--   drop table if exists advocacy_activities;
--   drop table if exists research_projects;
--   alter table kpi_quarterly
--     drop constraint if exists kpi_quarterly_communicator_rating_ck,
--     drop column if exists communicator_rating,
--     drop column if exists communicator_note,
--     drop column if exists communicator_set_at;
-- ═══════════════════════════════════════════════════════════════════════════
