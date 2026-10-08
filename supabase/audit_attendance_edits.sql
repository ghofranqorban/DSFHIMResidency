-- Attendance edit audit (READ-ONLY: nothing here changes data). Run each block in the Supabase SQL editor.
--
-- What the database can tell us today:
--   * mm_attendance / teaching_attendance keep ONE row per resident per session. marked_by is the
--     LAST person who saved that row. marked_at is set when the row is first created and is NOT
--     updated on a later edit, so it is the first-entry time, not the last-change time.
--   * No old value is kept, so a change from P to A cannot be reconstructed from these tables.
--   * activity_log holds a timestamped entry for each single-cell mark (att_mm / att_teach), but the
--     bulk "save the whole session" buttons do not write to it, so it is incomplete.

-- 1. Who last touched attendance rows, by person. own_rows = rows where they are marked on their
--    own record (a resident who marked themselves).
with a as (
  select 'Morning meeting' as kind, x.resident_id, x.status, x.marked_by, x.marked_at, s.session_date
    from mm_attendance x join mm_sessions s on s.id = x.session_id
  union all
  select 'Academic Day', x.resident_id, x.status, x.marked_by, x.marked_at, s.session_date
    from teaching_attendance x join teaching_sessions s on s.id = x.session_id
)
select coalesce(p.display_name, '(no profile)') as last_edited_by, p.role, a.kind,
       count(*) as rows_last_touched, min(a.session_date) as first_session, max(a.session_date) as last_session,
       count(*) filter (where p.resident_id = a.resident_id) as own_rows
  from a left join profiles p on p.id = a.marked_by
 group by 1, 2, 3
 order by p.role nulls last, rows_last_touched desc;

-- 2. Residents who marked their OWN attendance (the row's last editor is that resident).
with a as (
  select 'Morning meeting' as kind, x.resident_id, x.status, x.marked_by, x.marked_at, s.session_date
    from mm_attendance x join mm_sessions s on s.id = x.session_id
  union all
  select 'Academic Day', x.resident_id, x.status, x.marked_by, x.marked_at, s.session_date
    from teaching_attendance x join teaching_sessions s on s.id = x.session_id
)
select r.name as resident, a.kind, a.session_date, a.status, a.marked_at as first_entered_at
  from a join profiles p on p.id = a.marked_by and p.resident_id = a.resident_id
  join residents r on r.id = a.resident_id
 order by a.session_date desc, r.name;

-- 3. The timestamped log of single-cell marks: who, when, whom, what status, which session.
select created_at, display_name as done_by, action_type,
       details ->> 'resident_name' as resident, details ->> 'status' as status, details ->> 'session_date' as session_date
  from activity_log
 where action_type in ('att_mm', 'att_teach')
 order by created_at desc
 limit 500;

-- 4. The same log counted per person per month, to spot unusual volume.
select date_trunc('month', created_at)::date as month, display_name as done_by, count(*) as marks
  from activity_log
 where action_type in ('att_mm', 'att_teach')
 group by 1, 2
 order by 1 desc, marks desc;

-- 5. Who currently holds the attendance privilege.
select p.display_name, p.role, ap.privilege_key, ap.granted_at
  from account_privileges ap join profiles p on p.id = ap.profile_id
 where ap.privilege_key in ('edit_mm_attendance', 'edit_teach_attendance')
 order by p.display_name, ap.privilege_key;
