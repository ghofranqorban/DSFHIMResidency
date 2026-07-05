-- DSFH Residency Portal — Add comment field to attendance tables
-- Run in: Supabase → SQL Editor → New query

alter table mm_attendance
  add column if not exists comment text;

alter table teaching_attendance
  add column if not exists comment text;

-- Verify
-- select column_name from information_schema.columns
-- where table_name in ('mm_attendance','teaching_attendance') and column_name='comment';
