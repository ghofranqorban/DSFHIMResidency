-- Leave Plan: PD decision flags for over-cap "suggestion" picks
-- Lets the PD approve a suggested (over-cap) period as-is, distinguishing
-- it from a still-pending suggestion in the matrix view.
-- Run in: Supabase > SQL Editor > New query. Safe to re-run.

alter table public.leave_plan
  add column if not exists first_leave_approved boolean,
  add column if not exists second_leave_approved boolean;
