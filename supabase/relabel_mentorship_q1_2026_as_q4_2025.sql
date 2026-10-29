-- DSFH Residency Portal — one-off, 29 Oct 2026.
-- The learning plans filled in October 2026 were saved as Q1 of AY 2026-27 because the module always
-- pointed at the current year's quarter. The PD says they are the plans for Q4 of AY 2025-26 (Jul–Sep 2026),
-- and the module now defaults to the quarter just ended. This moves those rows. Rows that would collide with
-- an existing Q4 2025-26 row for the same resident are left where they are and listed afterwards.
-- Run once in the Supabase SQL Editor.

update mentorship_evaluations m
   set academic_year = 2025, quarter = 4, updated_at = now()
 where m.academic_year = 2026 and m.quarter = 1
   and not exists (select 1 from mentorship_evaluations x
                    where x.resident_id = m.resident_id and x.academic_year = 2025 and x.quarter = 4);

-- Expected: the first query lists the moved rows; the second should return nothing.
select id, resident_id, status, submitted_at from mentorship_evaluations where academic_year = 2025 and quarter = 4 order by resident_id;
select id, resident_id, status from mentorship_evaluations where academic_year = 2026 and quarter = 1;
