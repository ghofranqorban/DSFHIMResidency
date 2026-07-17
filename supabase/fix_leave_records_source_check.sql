-- Fix: leave requests (annual + educational) fail with
-- "new row for relation leave_records violates check constraint leave_records_source_check"
-- Root cause: submitLeaveRequest() inserts source:'resident' and
-- approveLeaveRequest() inserts source:'request', but the original check
-- constraint only allowed ('rota_import','manual'). App code is correct;
-- the constraint was never updated when the request/approve flow was built.
-- Run in: Supabase > SQL Editor > New query. Safe to re-run.

alter table public.leave_records drop constraint if exists leave_records_source_check;

alter table public.leave_records add constraint leave_records_source_check
  check (source in ('rota_import','manual','resident','request'));

-- Verify: log in as a resident, go to Annual Leave, "Request Leave",
-- submit an Educational (or Annual) leave request — should succeed.
-- Then as PD, approve it — should also succeed (uses source:'request').
