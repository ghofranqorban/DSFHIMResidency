-- DSFH Residency Portal — one-off, 29 Oct 2026.
-- Two self-assessments (residents 102 and 91) were submitted on 29 Oct 2026 while the tab still pointed at
-- the running half-year, so they are stored as period 1 of AY 2026-27 (Oct 2026 – Mar 2027). The half under
-- review now is period 2 of AY 2025-26 (Apr – Sep 2026). This moves every such row, skipping any resident
-- who already has a row for Apr – Sep 2026. Run once in the Supabase SQL Editor.

update self_assessments s
   set academic_year = 2025, period = 2, updated_at = now()
 where s.academic_year = 2026 and s.period = 1
   and not exists (select 1 from self_assessments x
                    where x.resident_id = s.resident_id and x.academic_year = 2025 and x.period = 2);

-- Expected: the first query lists the moved rows (residents 102 and 91); the second returns nothing.
select id, resident_id, status, submitted_at from self_assessments where academic_year = 2025 and period = 2 order by resident_id;
select id, resident_id, status from self_assessments where academic_year = 2026 and period = 1;
