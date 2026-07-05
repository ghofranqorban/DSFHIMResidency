-- DSFH Residency Portal — Fix: attendance status constraint
-- The original schema only allowed P/L/A but the UI has 5 statuses: P L A E O
-- Run in: Supabase → SQL Editor → New query

-- ─── mm_attendance ────────────────────────────────────────────────────────────
alter table mm_attendance
  drop constraint if exists mm_attendance_status_check;

alter table mm_attendance
  add constraint mm_attendance_status_check
  check (status in ('P','L','A','E','O'));

-- ─── teaching_attendance ──────────────────────────────────────────────────────
alter table teaching_attendance
  drop constraint if exists teaching_attendance_status_check;

alter table teaching_attendance
  add constraint teaching_attendance_status_check
  check (status in ('P','L','A','E','O'));

-- ─── Verify ───────────────────────────────────────────────────────────────────
-- After running, insert a test row with status='E' or 'O' — it should succeed.
-- select conname, consrc from pg_constraint where conname like '%attendance_status%';
