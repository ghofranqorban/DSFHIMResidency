-- DSFH Residency Portal — Fix: attendance RLS + deputy_pd role
-- Run in: Supabase → SQL Editor → New query
-- Fixes two bugs:
--   1. is_pd_or_chief() excluded deputy_pd, blocking all their writes
--   2. mm_attendance / teaching_attendance write policies excluded consultants,
--      even though the UI allows them to log attendance for their residents

-- ─── 1. Add deputy_pd to the is_pd_or_chief() helper ─────────────────────────
-- Every RLS policy that calls this function will automatically gain deputy_pd
-- support (residents, consultants, profiles, leave, rotations, counseling, etc.)
create or replace function is_pd_or_chief() returns boolean
language sql stable as $$
  select app_role() in ('pd', 'chief', 'deputy_pd');
$$;

-- ─── 2. Allow consultants to write attendance ─────────────────────────────────
-- The JS canLogMMAttendance() / canLogTeachAttendance() already shows the form
-- to consultants; the DB policy was too restrictive and caused a write error.

drop policy if exists mm_attendance_write on mm_attendance;
create policy mm_attendance_write on mm_attendance for all to authenticated
  using (
    is_pd_or_chief()
    or app_role() = 'consultant'
    or has_priv('edit_mm_attendance')
  )
  with check (
    is_pd_or_chief()
    or app_role() = 'consultant'
    or has_priv('edit_mm_attendance')
  );

drop policy if exists teaching_attendance_write on teaching_attendance;
create policy teaching_attendance_write on teaching_attendance for all to authenticated
  using (
    is_pd_or_chief()
    or app_role() = 'consultant'
    or has_priv('edit_teach_attendance')
  )
  with check (
    is_pd_or_chief()
    or app_role() = 'consultant'
    or has_priv('edit_teach_attendance')
  );

-- ─── Verify ──────────────────────────────────────────────────────────────────
-- After running, log in as a consultant and try marking attendance — should save.
-- Log in as deputy_pd and check you can edit residents, KPI, schedules, etc.
