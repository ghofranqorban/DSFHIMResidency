-- Leave Plan: backup/alternative period columns
-- Lets a resident who insists on an over-cap period ("suggestion") also name
-- a backup period the PD can fall back to when finalizing the rota.
-- Run in: Supabase > SQL Editor > New query. Safe to re-run.

alter table public.leave_plan
  add column if not exists first_leave_alt_key text,
  add column if not exists second_leave_alt_key text;
