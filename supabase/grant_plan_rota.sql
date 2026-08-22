-- Bring account_privileges' privilege_key CHECK constraint in line with the portal's
-- catalog. ALREADY RUN against production on 23 Aug 2026 — kept for repo consistency.
--
-- This is NOT a bug fix. The live database already accepted 'plan_rota' and 'edit_oncall'
-- (both were granted successfully in July 2026), so the constraint had been widened
-- directly in the Supabase SQL editor at some point and never captured as a file here.
-- Running this was a no-op in practice.
--
-- It still earns its place: rebuilding a database from the repo alone would run
-- schema.sql then migration_003_schedules.sql, whose list stops at six keys — and the
-- resulting DB could not store the two newest privileges. This file closes that gap.
--
-- The eight keys below are exactly the union of PRIV_LABELS_RESIDENT and
-- PRIV_LABELS_CONSULTANT in the portal. Add to both together, or the UI will offer a
-- toggle the database rejects.

alter table account_privileges drop constraint if exists account_privileges_privilege_key_check;
alter table account_privileges add constraint account_privileges_privilege_key_check check (privilege_key in (
  'edit_quiz_marks','edit_mm_attendance','edit_teach_attendance','edit_kpi_notes',
  'edit_mm_schedule','edit_teach_schedule','edit_oncall','plan_rota'
));

select pg_get_constraintdef(oid) as privilege_key_constraint
from pg_constraint
where conname = 'account_privileges_privilege_key_check';

-- Current holders. As of 23 Aug 2026 'plan_rota' is held by Dr. Farid and Dr. Deema,
-- both granted 2026-07-10 via Admin Panel → Accounts.
-- NOTE: residents.name holds first names only here (e.g. 'Dr. Farid'), so never match
-- these people on a surname.
select coalesce(r.name, c.name, p.display_name) as person,
       p.username, p.role, ap.privilege_key, ap.granted_at
from account_privileges ap
join profiles p on p.id = ap.profile_id
left join residents r on r.id = p.resident_id
left join consultants c on c.id = p.consultant_id
order by person, ap.privilege_key;
