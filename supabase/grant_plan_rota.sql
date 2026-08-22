-- Fix: Admin Panel → Accounts cannot grant `plan_rota` or `edit_oncall`.
--
-- Run this in Supabase → SQL Editor. Claude cannot execute it (RLS blocks the anon key).
--
-- THE BUG:
--   account_privileges has a CHECK constraint on privilege_key, last set by
--   migration_003_schedules.sql, listing only six keys. The portal has since added two
--   more to its catalog (PRIV_LABELS_RESIDENT):
--       plan_rota    "View all residents leave plan & manage AY rota planning"
--       edit_oncall  "Enter/edit On-Call schedule (Oncall Committee)"
--   Both appear as toggles in the UI, but switching either on fails with a
--   check-constraint violation, because the constraint never learned about them.
--
-- AFTER RUNNING THIS: grant `plan_rota` to Abdullah and Deema from
--   Admin Panel → Accounts → (their account) → Privileges.
-- Doing it in the UI avoids hardcoding name spellings here, and records granted_by
-- correctly. No further SQL needed.

alter table account_privileges drop constraint if exists account_privileges_privilege_key_check;
alter table account_privileges add constraint account_privileges_privilege_key_check check (privilege_key in (
  'edit_quiz_marks','edit_mm_attendance','edit_teach_attendance','edit_kpi_notes',
  'edit_mm_schedule','edit_teach_schedule','edit_oncall','plan_rota'
));

-- Verify the constraint now accepts all eight keys.
select pg_get_constraintdef(oid) as privilege_key_constraint
from pg_constraint
where conname = 'account_privileges_privilege_key_check';

-- Who currently holds anything (empty result for plan_rota is expected until you
-- grant it in the Admin Panel).
select coalesce(r.name, c.name, p.display_name) as person,
       p.username, p.role, ap.privilege_key, ap.granted_at
from account_privileges ap
join profiles p on p.id = ap.profile_id
left join residents r on r.id = p.resident_id
left join consultants c on c.id = p.consultant_id
order by person, ap.privilege_key;
