-- ============================================================
-- How wrong were the Morning Meeting percentages, exactly?
--
-- Follow-up to diagnose_row_caps.sql. That showed 29 residents each missing
-- exactly 1 attendance mark -- i.e. mm_attendance had just crossed 1000 rows
-- and one session's worth of marks was sitting past the cut-off.
--
-- The portal scores attendance like this (SFH_Residency_Portal.html:2166):
--     if (!s || s === 'O') return;   <-- missing row: skip, do not count
--     mmTotal++;                     <-- denominator
--     P/E -> +1     L -> +0.5     A -> +0
--
-- Because a missing row is skipped BEFORE mmTotal++, it drops out of the
-- numerator and the denominator together. So the error direction depends on
-- what the hidden mark actually was:
--     hidden 'A'   -> percentage was shown TOO HIGH (absence was invisible)
--     hidden 'P'   -> percentage was shown slightly TOO LOW
--     hidden 'L'   -> in between
--
-- Read-only. Run in Supabase -> SQL Editor.
--
-- ─── OUTCOME, 17 Aug 2026: no score was wrong enough to matter ──────────────
-- 1029 rows in mm_attendance, so 29 hidden, spread over 29 distinct residents
-- (one mark each -- nobody lost two). Of those, 9 were status 'O' and so moved
-- nothing at all; the remaining 20 are the residents Part B lists.
-- Worst case was a 4-point over-statement (85 shown, 81 correct). NO resident
-- crossed the 75% benchmark in either direction, so nothing was reissued.
-- reconcile_hidden_attendance.sql is the query that closed the 29-vs-20 gap.
-- ============================================================


-- ─── PART A ────────────────────────────────────────────────────────────────
-- Which session was hidden, and what were the marks on it?
with ranked as (
  select a.id, a.session_id, a.resident_id, a.status, s.academic_year,
         s.session_date, s.topic,
         row_number() over (order by a.id) as rn
  from mm_attendance a
  join mm_sessions s on s.id = a.session_id
)
select
  session_date,
  topic,
  count(*)                                as marks_hidden,
  count(*) filter (where status = 'P')    as hidden_present,
  count(*) filter (where status = 'L')    as hidden_late,
  count(*) filter (where status = 'A')    as hidden_absent,
  -- 'E' scores as a full present, 'O' is skipped outright. Without these two the
  -- columns above do not add up to marks_hidden -- 9 of the 29 were 'O'.
  count(*) filter (where status = 'E')    as hidden_excused,
  count(*) filter (where status = 'O')    as hidden_off
from ranked
where rn > 1000
group by session_date, topic
order by session_date;


-- ─── PART B ────────────────────────────────────────────────────────────────
-- Per resident: what the portal displayed vs what is actually correct.
-- 'delta_points' is how far off the displayed figure was, in percentage points.
-- Positive delta = the portal was showing a number HIGHER than the truth.
with ranked as (
  select a.resident_id, a.status, s.academic_year,
         row_number() over (order by a.id) as rn
  from mm_attendance a
  join mm_sessions s on s.id = a.session_id
),
cur as (
  select * from ranked
  where academic_year = (select max(academic_year) from mm_sessions)
    and status <> 'O'
),
calc as (
  select
    resident_id,
    sum(case when status in ('P','E') then 1.0
             when status = 'L'        then 0.5
             else 0 end)                                     as true_score,
    count(*)                                                 as true_total,
    sum(case when rn <= 1000
             then case when status in ('P','E') then 1.0
                       when status = 'L'        then 0.5
                       else 0 end
             else 0 end)                                     as shown_score,
    count(*) filter (where rn <= 1000)                        as shown_total,
    string_agg(status, ',') filter (where rn > 1000)          as hidden_marks
  from cur
  group by resident_id
)
select
  r.name                                                              as resident,
  c.hidden_marks,
  round(c.shown_score / nullif(c.shown_total, 0) * 100)                as pct_portal_showed,
  round(c.true_score  / nullif(c.true_total,  0) * 100)                as pct_correct,
  round(c.shown_score / nullif(c.shown_total, 0) * 100)
    - round(c.true_score / nullif(c.true_total, 0) * 100)              as delta_points,
  case
    when round(c.shown_score / nullif(c.shown_total,0) * 100) >= 75
     and round(c.true_score  / nullif(c.true_total, 0) * 100) <  75
      then 'CROSSED BENCHMARK - looked >=75% but is actually below'
    when round(c.shown_score / nullif(c.shown_total,0) * 100) <  75
     and round(c.true_score  / nullif(c.true_total, 0) * 100) >= 75
      then 'CROSSED BENCHMARK - looked <75% but actually meets it'
    else 'same side of 75% benchmark'
  end                                                                  as benchmark_effect
from calc c
join residents r on r.id = c.resident_id
order by abs(
  round(c.shown_score / nullif(c.shown_total, 0) * 100)
  - round(c.true_score / nullif(c.true_total, 0) * 100)
) desc, r.name;


-- ─── PART C ────────────────────────────────────────────────────────────────
-- Same check for the Academic Day / teaching side, which was not in the
-- earlier result set. If teaching_attendance is still under 1000 rows this
-- returns nothing, which is the good outcome.
with ranked as (
  select a.resident_id, a.status, s.academic_year,
         row_number() over (order by a.id) as rn
  from teaching_attendance a
  join teaching_sessions s on s.id = a.session_id
)
select
  r.name          as resident,
  count(*)        as marks_recorded,
  count(*) filter (where ranked.rn >  1000) as marks_missing
from ranked
join residents r on r.id = ranked.resident_id
where ranked.academic_year = (select max(academic_year) from teaching_sessions)
group by r.name
having count(*) filter (where ranked.rn > 1000) > 0
order by marks_missing desc;
