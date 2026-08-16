-- ============================================================
-- Reconcile the 29 hidden mm_attendance rows against the 20 residents
-- that showed a hidden mark in Part B.
--
-- mm_attendance holds 1029 rows, so the old unpaged read returned 1000 and hid 29.
-- Part B listed a hidden mark for only 20 residents, leaving 9 unexplained. There are
-- two benign explanations and this tells them apart:
--   (a) the row's status is 'O' (or blank), which the scorer skips before the
--       denominator increments, so it cannot move a percentage either way
--       (SFH_Residency_Portal.html:2166 -- `if(!s||s==='O')return;`);
--   (b) a resident had more than one hidden row, so 29 rows spread over 20 people.
--
-- Read-only. Three small results, no scrolling needed.
-- Run in: Supabase dashboard -> SQL Editor. Run each part separately.
--
-- NOTE the ranking assumption: an unsorted PostgREST read comes back in physical
-- storage order, which on an append-only table tracks id order but is not guaranteed
-- to. `row_number() over (order by a.id)` reproduces the likely cut, not a certainty.
-- ============================================================


-- ─── PART 1 ────────────────────────────────────────────────────────────────
-- The 29 hidden rows broken down by status. At most 5 rows out.
-- Anything on the 'skipped' line had zero effect on any percentage.
with ranked as (
  select a.id, a.resident_id, a.status,
         row_number() over (order by a.id) as rn
  from mm_attendance a
)
select
  status,
  count(*)                     as hidden_rows,
  count(distinct resident_id)  as residents,
  case status
    when 'O' then 'skipped by scorer - zero effect'
    when 'P' then 'counted present - hid a small UNDER-statement'
    when 'E' then 'counted present - hid a small UNDER-statement'
    when 'L' then 'counted half'
    when 'A' then 'counted absent - hid an OVER-statement'
    else          'unrecognised - scorer skips it'
  end as scorer_treatment
from ranked
where rn > 1000
group by status
order by hidden_rows desc;


-- ─── PART 2 ────────────────────────────────────────────────────────────────
-- The reconciliation in one row. `scored` is the number that could actually move
-- a percentage; it should equal the 20 residents Part B reported, unless Part 3
-- shows someone with more than one hidden row.
with ranked as (
  select a.id, a.resident_id, a.status,
         row_number() over (order by a.id) as rn
  from mm_attendance a
)
select
  count(*)                                                   as hidden_rows,
  count(distinct resident_id)                                as residents_touched,
  count(*) filter (where status = 'O' or status is null)     as skipped_by_scorer,
  count(*) filter (where status in ('P','E','L','A'))        as scored
from ranked
where rn > 1000;


-- ─── PART 3 ────────────────────────────────────────────────────────────────
-- Explanation (b): anyone holding more than one hidden row. Expect few or no rows.
-- Part B reports a single mark per resident, so a resident here means Part B
-- understated their delta.
with ranked as (
  select a.id, a.resident_id, a.status,
         row_number() over (order by a.id) as rn
  from mm_attendance a
)
select
  r.name                                       as resident,
  count(*)                                     as hidden_rows,
  string_agg(ranked.status, ',' order by ranked.id) as statuses
from ranked
join residents r on r.id = ranked.resident_id
where ranked.rn > 1000
group by r.name
having count(*) > 1
order by count(*) desc;
