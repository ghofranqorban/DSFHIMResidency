-- DSFH Residency Portal — audit_rls.sql
-- Run in: Supabase → SQL Editor → New query.  READ-ONLY: this changes nothing.
--
-- WHY: on 30 Sep 2026 a leftover `using (true)` SELECT policy on oncall_schedule was found
-- to have been exposing draft on-call schedules to residents since August. Postgres combines
-- permissive policies with OR, so adding a correct policy never replaces a loose one — the
-- loosest wins, silently. That table has been fixed. Nothing else has been checked.
--
-- Run each section and paste the output back. Section 1 is the one that matters most.

-- ─── 1. Tables with RLS switched OFF entirely ───────────────────────────────
-- THE WORST CASE. With RLS off, the table's rows are readable by anyone holding the
-- anon key — and that key is published in the portal's HTML by design. A table listed
-- here is effectively public to anyone who views source, unless it holds nothing sensitive.
select c.relname                as table_name,
       'RLS OFF - OPEN'         as status,
       pg_size_pretty(pg_total_relation_size(c.oid)) as size
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
 where n.nspname = 'public'
   and c.relkind = 'r'
   and not c.relrowsecurity
 order by c.relname;


-- ─── 2. Policies that let every signed-in user read every row ───────────────
-- `qual` of `true` means "no condition". Combined with OR against a correct policy,
-- this is exactly the bug that exposed the on-call drafts. Expect some legitimate hits:
-- residents / consultants / profiles / account_privileges are deliberately open because
-- the KPI leaderboard is computed client-side across everyone. Anything else here needs
-- a reason.
select tablename,
       policyname,
       cmd,
       roles::text,
       coalesce(qual, 'true (no condition)') as using_condition
  from pg_policies
 where schemaname = 'public'
   and (qual is null or btrim(qual) = 'true')
 order by cmd, tablename, policyname;


-- ─── 3. Policies that apply to anon / public, not just authenticated ────────
-- `{public}` includes the anon role, i.e. a visitor who never logged in.
-- Almost nothing should appear here.
select tablename, policyname, cmd, roles::text, qual
  from pg_policies
 where schemaname = 'public'
   and (roles::text like '%public%' or roles::text like '%anon%')
 order by tablename, policyname;


-- ─── 4. Write policies with no condition ────────────────────────────────────
-- An INSERT/UPDATE/DELETE (or ALL) policy whose check is `true` lets any signed-in
-- user modify those rows — including a resident editing their own evaluation.
select tablename, policyname, cmd, roles::text,
       coalesce(with_check, qual, 'true (no condition)') as write_condition
  from pg_policies
 where schemaname = 'public'
   and cmd in ('INSERT','UPDATE','DELETE','ALL')
   and (coalesce(with_check, qual) is null or btrim(coalesce(with_check, qual)) = 'true')
 order by tablename, policyname;


-- ─── 5. How many SELECT policies each table has ─────────────────────────────
-- More than one SELECT policy is the shape that hid the on-call leak: they OR together,
-- so the loosest one decides. Every table with 2+ needs reading as a whole, not
-- policy by policy.
select tablename,
       count(*) filter (where cmd in ('SELECT','ALL')) as read_policies,
       count(*)                                        as total_policies
  from pg_policies
 where schemaname = 'public'
 group by tablename
having count(*) filter (where cmd in ('SELECT','ALL')) > 1
 order by read_policies desc, tablename;


-- ─── 6. Tables with RLS ON but no policy at all ─────────────────────────────
-- Not a leak — the opposite. RLS with zero policies denies everyone, so a feature
-- reading this table is silently returning nothing.
select c.relname as table_name, 'RLS on, NO policies - reads return nothing' as status
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
 where n.nspname = 'public'
   and c.relkind = 'r'
   and c.relrowsecurity
   and not exists (select 1 from pg_policies p
                    where p.schemaname = 'public' and p.tablename = c.relname)
 order by c.relname;


-- ─── 7. Row counts for the sensitive tables ────────────────────────────────
-- Needed to interpret the resident-side probe. Signed in as a resident, these tables
-- returned 0 rows — but 0 means "RLS blocked it" AND "the table is empty", and from
-- outside they look identical. A table that is EMPTY has not been proven safe; it has
-- only not been tested yet. Any row here with count > 0 whose resident-side probe was 0
-- IS confirmed protected.
select 'counseling' t, count(*) from counseling
union all select 'mentor_notes',        count(*) from mentor_notes
union all select 'chief_votes',         count(*) from chief_votes
union all select 'best_resident_votes', count(*) from best_resident_votes
union all select 'leave_records',       count(*) from leave_records
union all select 'kpi_quarterly',       count(*) from kpi_quarterly
union all select 'promotion_log',       count(*) from promotion_log
union all select 'activity_log',        count(*) from activity_log
union all select 'notifications',       count(*) from notifications
union all select 'kpi_scores',          count(*) from kpi_scores
union all select 'quiz_scores',         count(*) from quiz_scores
 order by 1;


-- ─── 8. Full listing, for reference ─────────────────────────────────────────
-- Long. Only needed once the sections above have been triaged.
select tablename, policyname, cmd, roles::text, qual, with_check
  from pg_policies
 where schemaname = 'public'
 order by tablename, cmd, policyname;
