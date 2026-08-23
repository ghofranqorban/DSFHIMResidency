-- ═══════════════════════════════════════════════════════════════════════════
-- CanMEDS readiness check — READ ONLY, safe to run any time, changes nothing.
-- Sizes the data-entry job before the KPI page is rebuilt.
--
-- WHY: the v2c backfill reported 6 committee rows migrated + 4 kpi_scores rows
-- at score 0. committee_score is `int not null default 0`, so every kpi_scores
-- row is in one bucket or the other -- which means the ENTIRE legacy KPI table
-- is only 10 rows, against 38 active residents. This confirms how many
-- residents that actually covers, and what still has to be typed in.
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── 1. How thin is the legacy data really? ─────────────────────────────────
select 'active residents'                       as item, count(*)::text as value
  from residents where active and archived_at is null
union all
select 'kpi_scores rows (all years)',            count(*)::text            from kpi_scores
union all
select 'DISTINCT residents with any kpi_scores', count(distinct resident_id)::text from kpi_scores
union all
select 'academic years present in kpi_scores',   count(distinct academic_year)::text from kpi_scores
union all
select 'active residents with NO kpi_scores row at all', count(*)::text
  from residents r
 where r.active and r.archived_at is null
   and not exists (select 1 from kpi_scores k where k.resident_id = r.id);

-- ─── 2. Ramp AFTER the backfill ─────────────────────────────────────────────
-- The ramp figures you saw (not_yet_due 11 / behind 11 / not_met 16) came from
-- v2b's verify block, which ran BEFORE v2c inserted anything. Re-read it now:
-- the 7 migrated publications should have moved 7 residents into `met`.
select 'ramp: ' || ramp_state as item, count(*)::text as value
  from research_ramp group by ramp_state order by 1;

-- ─── 3. Committee coverage ──────────────────────────────────────────────────
select 'committee: KPI met'        as item, count(*)::text as value
  from committee_summary where committee_kpi_met
union all
select 'committee: no row (unknown, shows as awaiting entry)', count(*)::text
  from committee_summary where not committee_kpi_met;

-- ─── 4. Per-resident gap list — who needs what typed in ─────────────────────
-- The real work queue. `-` means nothing on file for that domain.
select r.level, r.name,
       coalesce(rp.n,0)::text  as research,
       coalesce(ad.n,0)::text  as campaigns,
       coalesce(vo.n,0)::text  as volunteering,
       coalesce(cm.n,0)::text  as committees,
       case when k.canmeds_verified_at is null then 'not verified' else 'verified' end as pd_check
  from residents r
  left join (select resident_id, count(*) n from research_projects group by 1) rp on rp.resident_id = r.id
  left join (select resident_id, count(*) n from advocacy_activities where kind='awareness_campaign' group by 1) ad on ad.resident_id = r.id
  left join (select resident_id, count(*) n from advocacy_activities where kind='volunteering' group by 1) vo on vo.resident_id = r.id
  left join (select resident_id, count(*) n from committee_memberships group by 1) cm on cm.resident_id = r.id
  left join kpi_scores k on k.resident_id = r.id and k.academic_year = 2025
 where r.active and r.archived_at is null
 order by r.level, r.name;
