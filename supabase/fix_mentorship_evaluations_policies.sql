-- DSFH Residency Portal — re-create the access rules for mentorship_evaluations
-- 28 Oct 2026: after add_mentorship_evaluations.sql the PD could read the (empty) table but every
-- insert answered "new row violates row-level security policy", which is what an RLS-enabled table
-- with no policies does. This file only re-creates the two policies and then lists them.

alter table mentorship_evaluations enable row level security;

drop policy if exists mentorship_evaluations_select on mentorship_evaluations;
create policy mentorship_evaluations_select on mentorship_evaluations for select to authenticated using (
  is_pd_or_chief()
  or (app_role() = 'consultant' and mentor_id = app_consultant_id())
  or (app_role() = 'resident' and resident_id = app_resident_id() and status = 'submitted')
);

drop policy if exists mentorship_evaluations_write on mentorship_evaluations;
create policy mentorship_evaluations_write on mentorship_evaluations for all to authenticated using (
  is_pd_or_chief()
  or (app_role() = 'consultant' and mentor_id = app_consultant_id())
) with check (
  is_pd_or_chief()
  or (app_role() = 'consultant' and mentor_id = app_consultant_id())
);

grant select, insert, update, delete on mentorship_evaluations to authenticated;

-- Expected: two rows, mentorship_evaluations_select (r) and mentorship_evaluations_write (*)
select polname, polcmd from pg_policy where polrelid = 'mentorship_evaluations'::regclass;
