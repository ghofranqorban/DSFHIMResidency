-- Block 13 of AY 2025-26 is 5 weeks. extend_block13_ay2025.sql already stretched the
-- straightforward rows; this closes the two cases it left for a human.
--
-- No new segments are created. A resident with 4 weeks of leave in a 5-week block is
-- ONE row: the team they cover in week 5, weeks = 1, leave_weeks = 4.
--
-- Run STEP 1 now. STEP 2 needs a team name per resident, so it is left commented out.

begin;

-- ── STEP 1 — the one split block: 2+2 becomes 2+3 ───────────────────────────
-- The extra week is at the end of the block (27 Sep - 3 Oct), so it lands on the
-- second segment. week_start stays 3, which is already correct.
update rotations
set weeks = 3
where academic_year = 2025 and block_number = 13 and resident_id = 100 and segment = 2;

commit;

-- ── STEP 2 — whole-block leave: who needs a team for week 5? ────────────────
-- These residents are booked off 30 Aug - 26 Sep and are back at work Sun 27 Sep,
-- but nothing says what they cover. Read the list, then fill in a team for each.
select r.resident_id, res.name, res.level, r.rotation_name, r.weeks, r.leave_weeks
from rotations r
join residents res on res.id = r.resident_id
where r.academic_year = 2025 and r.block_number = 13
  and r.rotation_name in ('Annual Leave','Maternity Leave')
order by res.level, res.name;

-- Then, per resident, turn the leave row into a 1-week rotation carrying 4 weeks of
-- leave at the START of the block. Copy this once per person and set the team:
--
--   update rotations
--   set rotation_name  = '<team>',
--       weeks          = 1,
--       leave_weeks    = 4,
--       leave_position = 'start'
--   where academic_year = 2025 and block_number = 13
--     and resident_id = <id> and segment = 1;

-- ── VERIFY (read-only) ──────────────────────────────────────────────────────
-- Every resident's block 13 should now account for all 5 weeks.
select res.name,
       sum(r.weeks) as rotation_weeks,
       sum(r.leave_weeks) as leave_weeks,
       sum(r.weeks) + sum(r.leave_weeks) as total,
       case when sum(r.weeks) + sum(r.leave_weeks) = 5 then 'OK - 5 weeks'
            else 'SHORT - week 5 unassigned' end as result
from rotations r
join residents res on res.id = r.resident_id
where r.academic_year = 2025 and r.block_number = 13
group by res.name
order by result desc, res.name;
