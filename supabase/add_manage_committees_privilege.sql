-- New account privilege: manage_committees.
-- Run in the Supabase SQL editor. Idempotent.
--
-- A resident or consultant who holds it can do on the Committees module what the PD, deputy PD and
-- chief can: assign leaders, co-leaders and members, add and remove faculty, add and edit meetings
-- and achievements, and edit the committees themselves. The Program Director grants it per account
-- under PD Admin Panel > Accounts > Account Privileges.
--
-- Policies on a table are ORed together, so these are ADDED beside the existing rules; none is
-- dropped or changed. The seat rules (the committee_membership_guard trigger: the Chief holds no
-- seat, R1 never leads, one leader and one co-leader per committee, and so on) still apply to
-- everyone, including a holder of this privilege.

-- 1. Let account_privileges accept the new key. The list is rebuilt from the keys already in use
--    plus the known ones, so no existing grant is rejected whatever the live constraint says.
do $$
declare keys text[];
begin
  select array(
    select privilege_key from account_privileges
    union
    select unnest(array['edit_quiz_marks','edit_mm_attendance','edit_teach_attendance','edit_kpi_notes',
                        'edit_mm_schedule','edit_teach_schedule','edit_oncall','plan_rota','manage_committees'])
  ) into keys;
  alter table account_privileges drop constraint if exists account_privileges_privilege_key_check;
  execute format('alter table account_privileges add constraint account_privileges_privilege_key_check check (privilege_key = any (%L::text[]))', keys);
end $$;

-- 2. The extra rules.
drop policy if exists committees_manage_priv on committees;
create policy committees_manage_priv on committees for all to authenticated
  using (has_priv('manage_committees')) with check (has_priv('manage_committees'));

drop policy if exists committee_memberships_manage_priv on committee_memberships;
create policy committee_memberships_manage_priv on committee_memberships for all to authenticated
  using (has_priv('manage_committees')) with check (has_priv('manage_committees'));

drop policy if exists committee_faculty_manage_priv on committee_faculty;
create policy committee_faculty_manage_priv on committee_faculty for all to authenticated
  using (has_priv('manage_committees')) with check (has_priv('manage_committees'));

drop policy if exists committee_meetings_manage_priv on committee_meetings;
create policy committee_meetings_manage_priv on committee_meetings for all to authenticated
  using (has_priv('manage_committees')) with check (has_priv('manage_committees'));

drop policy if exists committee_achievements_manage_priv on committee_achievements;
create policy committee_achievements_manage_priv on committee_achievements for all to authenticated
  using (has_priv('manage_committees')) with check (has_priv('manage_committees'));

-- A meeting is mirrored into calendar_events with its committee_id; only those rows are opened up.
drop policy if exists cal_ev_committee_manage_priv on calendar_events;
create policy cal_ev_committee_manage_priv on calendar_events for all to authenticated
  using (committee_id is not null and has_priv('manage_committees'))
  with check (committee_id is not null and has_priv('manage_committees'));

-- 3. Check what you got: six *_manage_priv rules, and the key list now including manage_committees.
select tablename, policyname, cmd from pg_policies
 where schemaname = 'public' and policyname like '%manage_priv' order by tablename;
select pg_get_constraintdef(oid) as privilege_key_constraint from pg_constraint
 where conname = 'account_privileges_privilege_key_check';
