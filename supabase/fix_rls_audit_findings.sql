-- DSFH Residency Portal — fix_rls_audit_findings.sql
-- Run in: Supabase → SQL Editor → New query. Safe to re-run.
--
-- From the 30 Sep 2026 audit of all 46 tables. Only the findings that are clear-cut are
-- fixed here. The ones needing a decision from the PD are listed at the bottom and
-- deliberately NOT changed.
--
-- Verified before writing this: the nightly promotion function is `security definer`, so
-- it runs as the owner and the promotion_log change below cannot block it.


-- ═══ 1. kpi_proposals was readable WITHOUT LOGGING IN ═══════════════════════
-- CONFIRMED EXPOSED: fetching it with only the anon key — the key printed in the
-- portal's own page source — returned 22 rows carrying resident_id, note and
-- proposed_by. That is per-resident performance commentary, readable by anyone who
-- viewed source. The policies were granted `TO public`, which includes the anon role,
-- not just signed-in users.
--
-- This only restores the intended audience (signed-in users). Whether a *resident*
-- should read other residents' proposals is a separate question — see section 6.

drop policy if exists kpi_proposals_select    on public.kpi_proposals;
drop policy if exists kpi_proposals_insert    on public.kpi_proposals;
drop policy if exists kpi_proposals_update_pd on public.kpi_proposals;

create policy kpi_proposals_select on public.kpi_proposals
  for select to authenticated using (true);

create policy kpi_proposals_insert on public.kpi_proposals
  for insert to authenticated with check (auth.uid() is not null);

create policy kpi_proposals_update_pd on public.kpi_proposals
  for update to authenticated
  using (exists (select 1 from profiles
                  where profiles.id = auth.uid()
                    and profiles.role = any (array['pd','deputy_pd'])));


-- ═══ 2. kpi_quarterly had the same public grant ═════════════════════════════
-- It reads as empty today, so nothing has leaked yet. That is timing, not safety:
-- the hole is open and the first row written falls through it.

drop policy if exists kpi_quarterly_select        on public.kpi_quarterly;
drop policy if exists kpi_quarterly_insert_update on public.kpi_quarterly;

create policy kpi_quarterly_select on public.kpi_quarterly
  for select to authenticated using (true);

create policy kpi_quarterly_insert_update on public.kpi_quarterly
  for all to authenticated
  using (exists (select 1 from profiles
                  where profiles.id = auth.uid()
                    and profiles.role = any (array['pd','deputy_pd','chief','consultant'])))
  with check (exists (select 1 from profiles
                       where profiles.id = auth.uid()
                         and profiles.role = any (array['pd','deputy_pd','chief','consultant'])));


-- ═══ 3. quiz_scores: ANY signed-in user could rewrite ANY score ═════════════
-- THE MOST SERIOUS FINDING. The policy was:
--     manage quiz_scores | ALL | {authenticated} | using true | with check true
-- No condition at all. Any resident could change their own quiz mark, or another
-- resident's, or delete the lot — straight from the browser console, no bug required.
-- This is exam-result integrity, not a privacy question.
--
-- Replaced with the audience the portal itself already enforces in canEditKPI() and
-- globalQuizEdit: PD/chief, a holder of 'edit_quiz_marks', or the resident's own mentor.
-- Same shape as the existing kpi_write policy on kpi_scores.

drop policy if exists "manage quiz_scores" on public.quiz_scores;

create policy quiz_scores_write on public.quiz_scores
  for all to authenticated
  using (
    is_pd_or_chief()
    or has_priv('edit_quiz_marks')
    or (app_role() = 'consultant'
        and resident_id in (select residents.id from residents
                             where residents.mentor_id = app_consultant_id()))
  )
  with check (
    is_pd_or_chief()
    or has_priv('edit_quiz_marks')
    or (app_role() = 'consultant'
        and resident_id in (select residents.id from residents
                             where residents.mentor_id = app_consultant_id()))
  );
-- "read quiz_scores" (select, true) is intentionally left alone: the KPI leaderboard is
-- computed client-side across every resident. See section 6.


-- ═══ 4. promotion_log: a blanket read defeated the PD-only one ══════════════
-- Two SELECT policies existed — `promotion_log_select` (true) and `promotion_select`
-- (is_pd_or_chief()). Permissive policies OR together, so `true` won and the PD-only
-- intent did nothing. Exactly the shape that hid the on-call draft leak.
-- It read as empty only because the first promotion has not run yet.
--
-- `promotion_log_insert` (with check true) let any signed-in user forge a promotion
-- record. `promotion_write` (ALL, is_pd_or_chief) already covers the PD's own inserts,
-- and the nightly job is security definer, so dropping it breaks neither.

drop policy if exists promotion_log_select on public.promotion_log;
drop policy if exists promotion_log_insert on public.promotion_log;


-- ═══ 5. Verify ══════════════════════════════════════════════════════════════
-- Expect: no rows granted to public/anon, and no unconditional write policies
-- except the ones named in section 6 as deliberate.

select 'still granted to anon/public' as check_name, tablename, policyname, cmd
  from pg_policies
 where schemaname='public' and (roles::text like '%public%' or roles::text like '%anon%')
union all
select 'unconditional write', tablename, policyname, cmd
  from pg_policies
 where schemaname='public' and cmd in ('INSERT','UPDATE','DELETE','ALL')
   and (coalesce(with_check, qual) is null or btrim(coalesce(with_check, qual)) = 'true')
 order by 1, 2;


-- ═══ 6. NOT CHANGED — these need the PD's decision, not a patch ═════════════
--
-- a) notifications: `auth_insert_notifs` has `with check true`, so any signed-in user can
--    post a notification to ANY other user. Tightening it to "your own profile only"
--    would break the portal, which legitimately notifies other people (leave-plan
--    reminders to residents, for instance). The right rule depends on which
--    notifications residents are meant to trigger. Left open pending that answer.
--
-- b) kpi_scores / quiz_scores / residents / profiles / consultants /
--    account_privileges / rotations are readable by every signed-in user. For the first
--    four this is LOAD-BEARING and must not be narrowed casually: the KPI and
--    Performance leaderboards are computed in the browser across all residents, and
--    restricting them silently collapses the denominator — already broken once, in
--    fix_kpi_scores_read_rls.sql. The open question is not whether to lock them, but
--    whether residents should see each other's FULL rows, or only the ranking the
--    interface chooses to show. That is a programme decision.
--
-- c) Several tables carry a carefully scoped SELECT policy that is already dead, because
--    a leftover blanket `true` policy ORs past it: residents (`residents_select`),
--    account_privileges (`privileges_select`), rotations (`rotations_select`).
--    Harmless while (b) stands, but misleading — anyone reading them will believe a
--    restriction is in force that is not. Delete the dead ones, or the blanket ones,
--    once (b) is decided. Do not leave both.
