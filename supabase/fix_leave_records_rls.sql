-- Fix: residents can never submit a leave request
-- ("new row violates row-level security policy for table leave_records")
-- Root cause: the original leave_write policy only allowed is_pd_or_chief()
-- to write leave_records at all — but submitLeaveRequest() has residents
-- insert their own pending "leave_request" row directly. They never had
-- permission to do this.
-- Run in: Supabase > SQL Editor > New query. Safe to re-run.

drop policy if exists leave_write on public.leave_records;

create policy leave_write on public.leave_records for all
  to authenticated
  using (is_pd_or_chief())
  with check (
    is_pd_or_chief()
    or (
      resident_id = app_resident_id()
      and type = 'leave_request'
      and approved = false
    )
  );

-- Note: this only opens INSERT of a resident's own pending request.
-- UPDATE/DELETE (approve/reject/edit) remain PD/chief-only, matching
-- existing app behavior (approveLeaveRequest/rejectLeaveRequest are
-- only exposed to PD/chief in the UI).

-- Verify: log in as a resident, go to Annual Leave, "Request Leave" —
-- submission should succeed. To check from SQL editor as postgres:
-- select id, resident_id from public.profiles where role='resident' limit 1;
-- (a null resident_id on the profile row will also cause this same error,
--  since app_resident_id() would return null and never match resident_id.)
