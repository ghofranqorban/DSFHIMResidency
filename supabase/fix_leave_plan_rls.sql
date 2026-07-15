-- Fix: leave_plan write policy rejects resident submissions
-- ("new row violates row-level security policy for table leave_plan")
-- Run in: Supabase > SQL Editor > New query. Safe to re-run.

drop policy if exists "write leave_plan" on public.leave_plan;

create policy "write leave_plan"
  on public.leave_plan for all
  to authenticated
  using (
    resident_id = app_resident_id()
    or (select role from public.profiles where id = auth.uid()) in ('pd','deputy_pd','chief','dio')
  )
  with check (
    resident_id = app_resident_id()
    or (select role from public.profiles where id = auth.uid()) in ('pd','deputy_pd','chief','dio')
  );

-- Verify: log in as a resident and run in the app (Leave Plan module) —
-- Save Draft / Submit should succeed. To check from SQL editor as postgres:
-- select id, resident_id from public.profiles where role='resident' limit 1;
-- (confirm resident_id is NOT NULL for the affected resident's profile — a
--  null resident_id on their profile row will also cause this same error,
--  since app_resident_id() would return null and never match resident_id.)
