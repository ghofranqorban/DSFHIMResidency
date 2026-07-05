-- Allow residents who have been granted an attendance privilege to see
-- all active residents (so they can mark attendance for the full cohort).
-- Run in: Supabase > SQL Editor > New query

-- Drop the existing policy and replace it with an extended version.
drop policy if exists residents_select on residents;

create policy residents_select on residents for select to authenticated using (
  is_pd_or_chief()
  or (app_role() = 'consultant' and mentor_id = app_consultant_id())
  or (app_role() = 'resident' and id = app_resident_id())
  or (
    app_role() = 'resident'
    and exists (
      select 1 from account_privileges
      where profile_id = auth.uid()
        and privilege_key in ('edit_mm_attendance','edit_teach_attendance')
    )
  )
);

-- Verify: log in as the privileged resident and run:
-- select id, name from residents order by name;
-- You should see all residents, not just yourself.
