-- ═══════════════════════════════════════════════════════════════════════════
-- KPI v2c — "verified" marker + backfill from the old boolean columns
-- Run once in: Supabase → SQL Editor → New query.  Safe to re-run.
--
-- PREREQUISITES, IN THIS ORDER:
--   1. add_canmeds_kpi_v2.sql   (research_projects, advocacy_activities)
--   2. add_canmeds_kpi_v2b.sql  (committee_memberships)   <-- NOT YET RUN as of 21 Aug
--   3. this file
-- Section 3 will fail with "relation committee_memberships does not exist" if
-- you skip step 2.
-- ═══════════════════════════════════════════════════════════════════════════
--
-- THE PROBLEM THIS SOLVES
--
-- The new tables start empty, so on launch day three of the seven CanMEDS roles
-- would read "not met" for all 38 residents. But "we have no record" is NOT the
-- same claim as "they did not do it", and rendering the second when you mean the
-- first accuses residents of failing something nobody has typed in yet.
--
-- Two mechanisms, together:
--   (a) BACKFILL recovers what the old booleans can still prove.
--   (b) canmeds_verified_at lets the PD say "I have checked this resident's year
--       and the record is complete", after which an empty domain legitimately
--       means not met. Before that tick, empty means "awaiting entry".
--
-- Without (b) the UI can never distinguish a genuinely idle R4 from one whose
-- data was never entered -- so underperformance would hide behind a grey pill
-- forever. One nullable timestamp per resident per year closes that hole.
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── 1. The "record is complete" marker ─────────────────────────────────────

alter table kpi_scores
  add column if not exists canmeds_verified_at timestamptz,
  add column if not exists canmeds_verified_by uuid references profiles(id);

comment on column kpi_scores.canmeds_verified_at is
  'Set when the PD confirms this resident-year CanMEDS record is complete. NULL = an empty domain means "awaiting entry" (neutral); NOT NULL = an empty domain means "not met" (a real fail). Clear it whenever new evidence is added.';


-- ─── 2. Scholar: bonus_published -> research_projects ───────────────────────
-- Only recovers THAT a publication existed, never its title or real date.
-- Ongoing unpublished projects were never stored as a boolean, so they cannot
-- be recovered at all -- the PD must enter those by hand.

insert into research_projects (resident_id, title, started_year, status, published_at, notes)
select k.resident_id,
       'Migrated from kpi_scores — title unknown',
       k.academic_year,
       'published',
       make_date(k.academic_year, 7, 1),        -- placeholder: 1 July of that AY
       'Auto-migrated from kpi_scores.bonus_published on ' || current_date ||
       '. REPLACE the title and the publication date.'
from kpi_scores k
where k.bonus_published
on conflict do nothing;


-- ─── 3. Health Advocate: volunteering -> advocacy_activities ────────────────
-- NOTE: only volunteering is recoverable. Awareness campaigns were never
-- recorded anywhere, so every campaign has to be entered from scratch. Health
-- Advocate will therefore sit at "awaiting entry" until that happens -- which is
-- correct, and is exactly why section 1 exists.

insert into advocacy_activities (resident_id, academic_year, kind, title, notes)
select k.resident_id, k.academic_year, 'volunteering',
       'Migrated from kpi_scores — title unknown',
       'Auto-migrated from kpi_scores.volunteering on ' || current_date || '. REPLACE the title.'
from kpi_scores k
where k.volunteering
on conflict do nothing;


-- ─── 4. Collaborator: committee_score > 0 -> committee_memberships ──────────
-- USER RULING, 21 Aug 2026: a committee_score of 0 does NOT mean "not a member".
-- So the inverse inference is unsafe and is NOT used here. Only the forward one
-- is: a score ABOVE zero proves participation, therefore membership.
--
-- Residents scoring 0 are left with NO row -- deliberately. They may or may not
-- hold a seat, and this migration must not assert either. They will show as
-- "awaiting entry" until the PD confirms, which is the honest state.
--
-- The committee NAME is not recoverable from an integer, so it lands as a
-- placeholder that must be edited before this is shown to anyone.

insert into committee_memberships (resident_id, academic_year, committee_name, is_chair, notes)
select k.resident_id, k.academic_year,
       'Committee — name to be confirmed',
       false,                                   -- chair is never inferred: scarce, and Performance only
       'Auto-migrated from kpi_scores.committee_score = ' || k.committee_score ||
       ' on ' || current_date || '. REPLACE the committee name.'
from kpi_scores k
where k.committee_score > 0
on conflict do nothing;


-- ─── 5. What was recovered, and what still needs typing in ──────────────────

select 'research_projects — migrated (need real titles)' as item,
       count(*)::text as value
  from research_projects where notes like 'Auto-migrated%'
union all
select 'advocacy: volunteering — migrated', count(*)::text
  from advocacy_activities where notes like 'Auto-migrated%'
union all
select 'advocacy: awareness campaigns — NOT recoverable, enter by hand', count(*)::text
  from advocacy_activities where kind = 'awareness_campaign'
union all
select 'committee — migrated from score > 0', count(*)::text
  from committee_memberships where notes like 'Auto-migrated%'
union all
select 'committee — residents with score 0, membership UNKNOWN', count(*)::text
  from kpi_scores where committee_score = 0
union all
select 'residents marked CanMEDS-verified', count(*)::text
  from kpi_scores where canmeds_verified_at is not null;


-- ─── 6. Cleanup helper — run later, after the PD has edited the placeholders ─
-- Lists every row still carrying a migrated placeholder, so nothing ships with
-- "title unknown" on screen.
--
-- select 'research' as src, r.id, res.name, r.title
--   from research_projects r join residents res on res.id = r.resident_id
--  where r.title like 'Migrated from kpi_scores%'
-- union all
-- select 'advocacy', a.id, res.name, a.title
--   from advocacy_activities a join residents res on res.id = a.resident_id
--  where a.title like 'Migrated from kpi_scores%'
-- union all
-- select 'committee', c.id, res.name, c.committee_name
--   from committee_memberships c join residents res on res.id = c.resident_id
--  where c.committee_name like 'Committee — name to be confirmed%'
-- order by 1, 3;


-- ═══════════════════════════════════════════════════════════════════════════
-- ROLLBACK — removes ONLY the auto-migrated rows, leaving hand-entered data:
--
--   delete from research_projects   where notes like 'Auto-migrated%';
--   delete from advocacy_activities where notes like 'Auto-migrated%';
--   delete from committee_memberships where notes like 'Auto-migrated%';
--   alter table kpi_scores
--     drop column if exists canmeds_verified_at,
--     drop column if exists canmeds_verified_by;
-- ═══════════════════════════════════════════════════════════════════════════
