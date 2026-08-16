-- Correct `weeks` on pre-existing blocks that were already split by leave.
--
-- migrate_rotations_segments.sql backfilled weeks = 4 on every existing row. That is
-- right for a whole block, but rows written before the migration that carry
-- leave_weeks = 2 only ran the rotation for 2 of the block's 4 weeks. Left as-is they
-- count as 4 + 2 = 6 weeks and inflate the cumulative SCFHS totals.
--
-- The imported historical rows already set weeks correctly, so they do not match here.
-- Run AFTER the migration. Safe to run more than once.

begin;

-- 1. Show what is about to change.
select r.id, res.username, r.academic_year, r.block_number, r.segment,
       r.rotation_name, r.weeks as weeks_now, r.leave_weeks,
       4 - r.leave_weeks as weeks_after
from rotations r
join residents res on res.id = r.resident_id
where r.leave_weeks > 0 and r.weeks + r.leave_weeks > 4
order by res.username, r.academic_year, r.block_number;

-- 2. Apply.
update rotations
set weeks = 4 - leave_weeks
where leave_weeks > 0 and weeks + leave_weeks > 4;

commit;

-- Verify: should return zero rows.
--   select * from rotations where weeks + coalesce(leave_weeks,0) > 4;
