-- Block 13 of AY 2025-26 runs 5 weeks (30 Aug - 3 Oct 2026) instead of the usual 4,
-- so the year meets AY 2026-27 (starts Sun 4 Oct 2026) with no uncovered week between.
--
-- This file makes the SCFHS week counting agree with that. `rotations.weeks` records how
-- long the rotation in THIS row actually ran, and histWeeksFor() sums it for training
-- credit, so block 13 rotations must say 5 rather than the column default of 4.
--
-- LEAVE DOES NOT STRETCH. A resident on leave in block 13 comes back to work for week 5.
-- So the leave side keeps the weeks it was booked for and only the ROTATION side absorbs
-- the extra week:  rotation weeks = 5 - leave_weeks.
--
-- Safe to run more than once. Read-only reports print before and after the change.

begin;

-- ── 0. Before picture ────────────────────────────────────────────────────────
-- Run this on its own first if you want to look before changing anything.
select 'BEFORE' as stage, segment, leave_weeks, weeks, count(*) as rows
from rotations
where academic_year = 2025 and block_number = 13
group by segment, leave_weeks, weeks
order by segment, leave_weeks, weeks;

-- ── 1. The CHECK constraint currently forbids 5 ──────────────────────────────
-- migrate_rotations_segments.sql created `weeks between 1 and 4`. A 5-week block is
-- rejected outright until this is widened, so this must happen before any update.
alter table rotations drop constraint if exists rotations_weeks_check;
alter table rotations add  constraint rotations_weeks_check check (weeks between 1 and 5);

-- ── 2. Full-block rotations: 4 -> 5 weeks ────────────────────────────────────
-- Only rows that are the sole segment for that resident/block, carry no leave split,
-- and are an actual rotation (not a whole block of leave - see the report in step 4).
update rotations r
set weeks = 5
where r.academic_year = 2025
  and r.block_number  = 13
  and coalesce(r.leave_weeks, 0) = 0
  and r.rotation_name not in ('Annual Leave', 'Maternity Leave')
  and r.weeks <> 5
  and not exists (
    select 1 from rotations o
    where o.resident_id = r.resident_id
      and o.academic_year = r.academic_year
      and o.block_number  = r.block_number
      and o.segment <> r.segment
  );

-- ── 3. Leave-split rows: rotation takes the extra week, leave keeps its own ──
-- e.g. 2 weeks annual leave + rotation  ->  leave stays 2, rotation becomes 3.
update rotations r
set weeks = 5 - r.leave_weeks
where r.academic_year = 2025
  and r.block_number  = 13
  and coalesce(r.leave_weeks, 0) > 0
  and r.weeks <> 5 - r.leave_weeks
  and 5 - r.leave_weeks between 1 and 5
  and not exists (
    select 1 from rotations o
    where o.resident_id = r.resident_id
      and o.academic_year = r.academic_year
      and o.block_number  = r.block_number
      and o.segment <> r.segment
  );

commit;

-- ── 4. Rows this file deliberately did NOT touch - decide these by hand ──────
--
-- (a) TWO-SEGMENT (split rotation) blocks. Every split in five years of data is 2+2,
--     but a 5-week block cannot split evenly. The extra week sits at the END of the
--     block (27 Sep - 3 Oct), so the later segment is the natural place to put it
--     (2+3), but that is a scheduling decision, not something to infer. Nothing was
--     changed for these residents.
select 'NEEDS DECISION: split rotation' as issue,
       r.resident_id, res.name, r.segment, r.rotation_name, r.weeks, r.leave_weeks
from rotations r
join residents res on res.id = r.resident_id
where r.academic_year = 2025 and r.block_number = 13
  and exists (
    select 1 from rotations o
    where o.resident_id = r.resident_id
      and o.academic_year = r.academic_year
      and o.block_number  = r.block_number
      and o.segment <> r.segment
  )
order by res.name, r.segment;

-- To apply the 2+3 default once you have decided, for one resident:
--   update rotations set weeks = 3
--   where academic_year = 2025 and block_number = 13
--     and resident_id = <id> and segment = 2;

-- (b) WHOLE-BLOCK LEAVE. These residents were booked off for all of block 13. Their
--     leave stays 4 weeks and they are back at work on Sun 27 Sep 2026 - but nothing
--     records what they cover in week 5. Needs a rotation assigning for that week.
select 'NEEDS DECISION: back at work for week 5' as issue,
       r.resident_id, res.name, r.rotation_name, r.weeks
from rotations r
join residents res on res.id = r.resident_id
where r.academic_year = 2025 and r.block_number = 13
  and r.rotation_name in ('Annual Leave', 'Maternity Leave')
order by res.name;

-- ── 5. After picture - confirm the change landed ─────────────────────────────
select 'AFTER' as stage, segment, leave_weeks, weeks, count(*) as rows
from rotations
where academic_year = 2025 and block_number = 13
group by segment, leave_weeks, weeks
order by segment, leave_weeks, weeks;

-- Expect: single-segment rotation rows now weeks = 5; leave-split rows weeks = 5 minus
-- their leave_weeks; whole-block leave and two-segment rows unchanged, listed above.

-- Sanity check that nothing outside block 13 of AY 2025 moved:
select academic_year, block_number, count(*) as rows_with_weeks_5
from rotations
where weeks = 5
group by academic_year, block_number
order by academic_year, block_number;
-- Expect exactly one row: academic_year 2025, block_number 13.
