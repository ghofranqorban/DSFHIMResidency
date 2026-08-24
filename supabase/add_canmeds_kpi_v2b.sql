-- ═══════════════════════════════════════════════════════════════════════════
-- KPI v2b — committee split (Option C) + the `behind` ramp state
-- Run once in: Supabase → SQL Editor → New query.  Safe to re-run.
-- PREREQUISITE: add_canmeds_kpi_v2.sql must already have run (it creates
-- research_projects, which the replaced view below reads).
-- ═══════════════════════════════════════════════════════════════════════════
--
-- WHY (decided 21 Aug 2026, after checking the SCFHS source text):
--
-- The SCFHS Saudi Board IM Curriculum 2015 uses the CanMEDS **2005** roles, so
-- the role is called MANAGER, not Leader. Its enabling competency 4.1 is
-- "Chair or participate in committees and meetings effectively", and "Effective
-- meetings and committees" is a Manager Element. Committee work is therefore
-- Manager in SCFHS's own words -- NOT Collaborator, which is where we had put it.
-- Collaborator's nearest item (1.6) is "participate in INTERPROFESSIONAL TEAM
-- meetings", i.e. clinical MDT, not programme committees.
--
-- Option C splits the activity instead of the role, which respects both texts:
--
--   committee MEMBERSHIP -> Collaborator, BINARY KPI.
--       Fair, because the PD guarantees a seat to every resident, so every
--       resident can clear it through their own effort.
--
--   committee CHAIR      -> Manager, PERFORMANCE ONLY, never a KPI.
--       Chair roles are scarce and awarded by someone else. Making a scarce
--       thing a KPI fails residents for arithmetic rather than for conduct.
--
-- kpi_scores.committee_score (0-10) is UNTOUCHED and still serves as the
-- Collaborator gradient. This table adds what a single integer cannot express:
-- which committees, how many, and who chairs.
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── 1. Committee memberships ───────────────────────────────────────────────

create table if not exists committee_memberships (
  id             bigint generated always as identity primary key,
  resident_id    bigint not null references residents(id) on delete cascade,
  -- Portal numbering: cycle start year, e.g. 2025 = AY 2025-26.
  academic_year  int not null,
  committee_name text not null,
  -- TRUE = chairs it. Feeds the Manager PERFORMANCE gradient only.
  -- Never let this gate a KPI: seats are guaranteed, chairs are not.
  is_chair       boolean not null default false,
  appointed_at   date,
  notes          text,
  updated_by     uuid references profiles(id),
  updated_at     timestamptz not null default now(),
  created_at     timestamptz not null default now()
);

-- A resident sits on a given committee once per year; across years is fine.
create unique index if not exists committee_memberships_res_year_name_ux
  on committee_memberships (resident_id, academic_year, lower(committee_name));

create index if not exists committee_memberships_resident_ix
  on committee_memberships (resident_id);

comment on table committee_memberships is
  'One row per resident per committee per year. MEMBERSHIP feeds the CanMEDS Collaborator binary KPI (seat guaranteed to all); IS_CHAIR feeds the Manager Performance gradient and must never gate a KPI, because chairs are scarce.';
comment on column committee_memberships.is_chair is
  'Performance signal only. Scarce and awarded by others, so it fails the fairness test for a KPI threshold.';


-- ─── 2. RLS ─────────────────────────────────────────────────────────────────
-- Same shape as research_projects / advocacy_activities: read by every
-- authenticated user because the programme-level KPI and the Performance Report
-- leaderboard are computed client-side across ALL residents. Narrowing SELECT
-- would silently collapse the denominator per session -- the bug already fixed
-- once in fix_kpi_scores_read_rls.sql. Writes stay with PD/chief/deputy_pd or
-- the resident's own assigned mentor.

alter table committee_memberships enable row level security;

drop policy if exists committee_memberships_select on committee_memberships;
create policy committee_memberships_select on committee_memberships
  for select to authenticated using (true);

drop policy if exists committee_memberships_write on committee_memberships;
create policy committee_memberships_write on committee_memberships for all to authenticated
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


-- ─── 3. Committee summary view ──────────────────────────────────────────────
-- Splits the two layers explicitly so the app cannot accidentally score a chair
-- role. `committee_kpi_met` is the ONLY column the KPI layer may read.

drop view if exists committee_summary;
create view committee_summary with (security_invoker = true) as
select
  r.id                                            as resident_id,
  r.name,
  r.level,
  count(c.id)                                     as committee_count,
  count(c.id) filter (where c.is_chair)           as chair_count,
  -- KPI layer (binary). Seat is guaranteed, so this is clearable by everyone.
  -- The Chief and Co-Chief hold no committee seat at all (enforced by
  -- committee_membership_guard in add_committees.sql), so they would otherwise
  -- fail a KPI they are structurally barred from meeting. The chief role itself
  -- clears it. Deliberately binary: no committee_count or chair_count credit, so
  -- the Manager gradient stays winnable by residents who actually lead one.
  (count(c.id) > 0 or r.chief_role is not null)   as committee_kpi_met
from residents r
left join committee_memberships c on c.resident_id = r.id
where r.active and r.archived_at is null
group by r.id, r.name, r.level;

comment on view committee_summary is
  'Collaborator KPI (committee_kpi_met, binary) and Manager Performance gradient (committee_count, chair_count). Only committee_kpi_met may gate a KPI.';


-- ─── 4. Replace research_ramp: add the `behind` state ───────────────────────
-- v2 folded "R2 with nothing on file" into 'at_risk'. That was a label
-- collision: 'at_risk' already means "project registered but no IRB yet", and an
-- R2 with NOTHING is strictly worse than one with a registered project. Merging
-- them left the PD unable to tell the two apart on a list. Now six states:
--
--   met          >=1 published
--   on_track     IRB approval on file
--   at_risk      project registered, no IRB yet
--   behind       nothing on file, R2 -- the ramp expects a project identified
--   not_met      nothing on file, R3 or R4
--   not_yet_due  nothing on file, R1
--
-- Ramp: R1 nothing due / R2 project identified / R3 IRB approved / R4 published.
-- Column list is unchanged, so anything already selecting from this view keeps
-- working -- but any code that switches on ramp_state must learn 'behind'.

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
    when r.level = 'R2'                                         then 'behind'
    else 'not_met'
  end as ramp_state
from residents r
left join research_projects p on p.resident_id = r.id
where r.active and r.archived_at is null
group by r.id, r.name, r.level;

comment on view research_ramp is
  'Per-resident CanMEDS Scholar ramp: met / on_track / at_risk / behind / not_met / not_yet_due. behind = R2 with nothing registered, distinct from at_risk = registered but no IRB.';


-- ─── 5. Verify ──────────────────────────────────────────────────────────────
-- Expect: committee_memberships 0 rows; every active resident in both views;
-- ramp_state showing not_yet_due for R1s, behind for R2s, not_met for R3/R4
-- while research_projects is still empty.

select 'committee_memberships rows' as item, count(*)::text as value from committee_memberships
union all
select 'committee_summary residents', count(*)::text from committee_summary
union all
select 'ramp: ' || ramp_state, count(*)::text from research_ramp group by ramp_state;


-- ═══════════════════════════════════════════════════════════════════════════
-- ROLLBACK (paste separately if you need to undo this)
--
--   drop view  if exists committee_summary;
--   drop table if exists committee_memberships;
--   -- then re-run section 5 of add_canmeds_kpi_v2.sql to restore the 5-state view
-- ═══════════════════════════════════════════════════════════════════════════
