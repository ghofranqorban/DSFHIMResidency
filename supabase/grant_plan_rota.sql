-- Grant the `plan_rota` privilege to Abdullah Farid and Deema Bakhashab.
--
-- Run this in Supabase → SQL Editor. Claude cannot execute it (RLS blocks the anon key).
--
-- WHY A MIGRATION AND NOT JUST THE ADMIN PANEL:
--   account_privileges has a CHECK constraint on privilege_key. It was last set by
--   migration_003_schedules.sql and lists only six keys. Two privileges that the portal
--   already offers in Admin Panel → Accounts are MISSING from it:
--       plan_rota    (PRIV_LABELS_RESIDENT, portal :7643)
--       edit_oncall  (PRIV_LABELS_RESIDENT, portal :7642)
--   Toggling either one in the Admin Panel therefore fails with a check-constraint
--   violation. Step 1 below widens the constraint so both work from the UI from now on.
--
-- Neither Abdullah nor Deema holds a chief role — this is a privilege grant only,
-- their profiles.role stays 'resident'.

begin;

-- ─── 1. Widen the privilege_key constraint to match the portal's catalog ────────
alter table account_privileges drop constraint if exists account_privileges_privilege_key_check;
alter table account_privileges add constraint account_privileges_privilege_key_check check (privilege_key in (
  'edit_quiz_marks','edit_mm_attendance','edit_teach_attendance','edit_kpi_notes',
  'edit_mm_schedule','edit_teach_schedule','edit_oncall','plan_rota'
));

-- ─── 2. Preflight: confirm exactly one profile matches each name ────────────────
-- Read this output before trusting step 3. Expect precisely two rows.
-- `residents.name` is stored with a 'Dr. ' prefix, hence the ILIKE.
select p.id as profile_id, p.username, p.role, r.name, r.level, r.year_started
from profiles p
join residents r on r.id = p.resident_id
where r.name ilike '%Abdullah%Farid%'
   or r.name ilike '%Deema%Bakhashab%'
order by r.name;

-- ─── 3. Grant ───────────────────────────────────────────────────────────────────
-- Aborts rather than half-granting if the names do not resolve to exactly 2 profiles.
do $$
declare n int;
begin
  select count(*) into n
  from profiles p join residents r on r.id = p.resident_id
  where r.name ilike '%Abdullah%Farid%' or r.name ilike '%Deema%Bakhashab%';

  if n <> 2 then
    raise exception 'Expected 2 matching profiles for Abdullah Farid + Deema Bakhashab, found %. Check the step-2 output and fix the name filters before re-running.', n;
  end if;
end $$;

insert into account_privileges (profile_id, privilege_key, granted_by)
select p.id, 'plan_rota', (select id from profiles where role = 'pd' order by created_at limit 1)
from profiles p
join residents r on r.id = p.resident_id
where r.name ilike '%Abdullah%Farid%'
   or r.name ilike '%Deema%Bakhashab%'
on conflict (profile_id, privilege_key) do nothing;

commit;

-- ─── 4. Verify ──────────────────────────────────────────────────────────────────
-- Expect two rows, both privilege_key = 'plan_rota'.
select r.name, p.username, ap.privilege_key, ap.granted_at
from account_privileges ap
join profiles p on p.id = ap.profile_id
join residents r on r.id = p.resident_id
where ap.privilege_key = 'plan_rota'
order by r.name;
