-- ============================================================
-- Diagnose the PostgREST 1000-row cap
--
-- Background: PostgREST returns at most 1000 rows per request and gives NO
-- error when it cuts the rest off. The portal used to read several tables in
-- one plain request, so any table past 1000 rows was silently returning only
-- part of itself. The reads are now paged, but this tells us how much data was
-- being hidden before the fix -- i.e. whether anything shown to residents or
-- counted in KPI was computed from partial data.
--
-- Read-only. Nothing here writes or changes anything.
-- Run in: Supabase dashboard -> SQL Editor -> New query -> paste -> Run.
-- Run each numbered part separately (the editor shows one result grid at a time).
-- ============================================================


-- ─── PART 1 ────────────────────────────────────────────────────────────────
-- Whole-table reads. Anything over 1000 was being truncated before the fix.
select
  table_name,
  row_count,
  case
    when row_count > 1000 then 'WAS TRUNCATED - ' || (row_count - 1000) || ' rows hidden'
    when row_count > 800  then 'close to cap - will truncate soon'
    else 'under cap - was fine'
  end as verdict
from (
  select 'mm_attendance'       as table_name, count(*) as row_count from mm_attendance
  union all select 'teaching_attendance', count(*) from teaching_attendance
  union all select 'mm_sessions',         count(*) from mm_sessions
  union all select 'teaching_sessions',   count(*) from teaching_sessions
  union all select 'mm_highlights',       count(*) from mm_highlights
  union all select 'leave_records',       count(*) from leave_records
  union all select 'quiz_scores',         count(*) from quiz_scores
  union all select 'rotations',           count(*) from rotations
) t
order by row_count desc;


-- ─── PART 2 ────────────────────────────────────────────────────────────────
-- On-call is read one academic year at a time, so the cap applies per year.
-- Expect roughly 1700 rows in a fully-scheduled year (4 slots per weekday,
-- 6 per weekend day) -- i.e. over the cap on its own.
select
  academic_year,
  count(*) as row_count,
  case when count(*) > 1000
       then 'WAS TRUNCATED - ' || (count(*) - 1000) || ' rows hidden'
       else 'under cap - was fine' end as verdict
from oncall_schedule
group by academic_year
order by academic_year;


-- ─── PART 3 ────────────────────────────────────────────────────────────────
-- Confirms the two kpi_scores reads were safe to leave unpaged.
-- Expect roughly one row per resident per year, so a few dozen at most.
select academic_year, count(*) as row_count
from kpi_scores
group by academic_year
order by academic_year;


-- ─── PART 4 ────────────────────────────────────────────────────────────────
-- The important one: WHICH YEARS of attendance were being lost?
--
-- Attendance stores one row per session per resident, so it grows fastest of
-- any table here. The old read had no sort order, and an unsorted PostgREST
-- read comes back in physical storage order, which on an append-only table
-- runs oldest-first. So the 1000 rows that survived were most likely the
-- OLDEST ones -- meaning the CURRENT year's attendance is what went missing.
--
-- 'likely_lost' is an estimate of scale, not an exact list: storage order is
-- close to id order but Postgres does not guarantee it.
with ranked as (
  select a.id, s.academic_year, row_number() over (order by a.id) as rn
  from mm_attendance a
  join mm_sessions s on s.id = a.session_id
)
select
  'mm_attendance' as source,
  academic_year,
  count(*)                                as total_rows,
  count(*) filter (where rn <= 1000)      as likely_returned,
  count(*) filter (where rn >  1000)      as likely_lost
from ranked
group by academic_year

union all

select
  'teaching_attendance',
  academic_year,
  count(*),
  count(*) filter (where rn <= 1000),
  count(*) filter (where rn >  1000)
from (
  select a.id, s.academic_year, row_number() over (order by a.id) as rn
  from teaching_attendance a
  join teaching_sessions s on s.id = a.session_id
) tr
group by academic_year

order by source, academic_year;


-- ─── PART 5 ────────────────────────────────────────────────────────────────
-- Translates Part 4 into the number that actually matters: for the current
-- year, how many attendance marks exist per resident, and how many of those
-- the portal was likely showing. A big gap here means the resident's Morning
-- Meeting / Academic Day percentage -- and their KPI score -- was understated.
with ranked as (
  select a.id, a.resident_id, s.academic_year, row_number() over (order by a.id) as rn
  from mm_attendance a
  join mm_sessions s on s.id = a.session_id
)
select
  r.name                                          as resident,
  count(*)                                        as marks_recorded,
  count(*) filter (where ranked.rn <= 1000)       as marks_portal_saw,
  count(*) filter (where ranked.rn >  1000)       as marks_missing
from ranked
join residents r on r.id = ranked.resident_id
where ranked.academic_year = (select max(academic_year) from mm_sessions)
group by r.name
having count(*) filter (where ranked.rn > 1000) > 0
order by marks_missing desc;
