-- DSFH Residency Portal — fix_oncall_draft_leak.sql
-- Run in: Supabase → SQL Editor → New query. Safe to re-run.
--
-- SYMPTOM (reported 27 Aug 2026): residents could see the block 13 on-call
-- schedule while it was still a draft.
--
-- ROOT CAUSE: two SELECT policies on oncall_schedule, and Postgres combines
-- permissive policies with OR. add_oncall_draft_publish.sql installs the correct
-- gate:
--
--     oncall_schedule_select ... using (published or is_pd_or_chief()
--                                       or has_priv('edit_oncall'))
--
-- and before creating it drops two older names. But fix_read_rls_for_all.sql had
-- already created a THIRD policy under a name that drop list never mentions:
--
--     "oncall read all authenticated" ... using (true)
--
-- so both survive, and `using (true)` swallows the publish check whole.
--
-- WHY ONLY BLOCK 13 LOOKED WRONG: add_oncall_draft_publish.sql ends with
-- `update oncall_schedule set published=true where published=false`, so every
-- block that existed at the time was backfilled as published. Block 13 is the
-- first block drafted since, so it is the only one where the leak is visible.
-- Every earlier block looked correct by accident, not by enforcement.
--
-- Do NOT touch the other four tables in fix_read_rls_for_all.sql. The blanket
-- reads on residents / consultants / profiles / account_privileges are
-- load-bearing: the KPI and Performance leaderboard are computed client-side
-- across ALL residents, and narrowing those SELECTs silently collapses the
-- denominator per session — a bug already fixed once in fix_kpi_scores_read_rls.sql.


-- ─── 1. Drop the blanket policy, but only if the real gate exists ───────────
-- Guard rather than a bare DROP: if add_oncall_draft_publish.sql was never run
-- in this database, removing the blanket policy would leave NO readable policy
-- and hide the on-call schedule from every resident. Failing loudly is better.

do $$
begin
  if not exists (
    select 1 from pg_policies
     where schemaname = 'public'
       and tablename  = 'oncall_schedule'
       and policyname = 'oncall_schedule_select'
  ) then
    raise exception
      'ABORTED: policy oncall_schedule_select is missing. Run add_oncall_draft_publish.sql first, otherwise dropping the blanket policy hides on-call from everyone.';
  end if;

  execute 'drop policy if exists "oncall read all authenticated" on public.oncall_schedule';
end $$;


-- ─── 2. Verify ──────────────────────────────────────────────────────────────
-- Expect exactly ONE select policy left, whose qual mentions `published`.
-- If a row with qual = 'true' is still listed, the leak is still open.

select policyname, cmd, qual
  from pg_policies
 where schemaname = 'public' and tablename = 'oncall_schedule'
 order by cmd, policyname;


-- ─── 3. THE OTHER HALF OF THIS FIX IS NOT SQL ───────────────────────────────
-- supabase/functions/ical/index.ts builds its client with the SERVICE-ROLE key,
-- which bypasses RLS completely. The policy fixed above therefore does nothing
-- for the calendar feed: draft shifts were being pushed to subscribers' phones
-- regardless. Three queries in that file now carry .eq("published", true) —
-- oncall_schedule, mm_sessions and teaching_sessions (mm and teaching were
-- leaking drafts the same way; calendar_events and rotations have no published
-- column and are correctly unfiltered).
--
-- That change only takes effect once the function is redeployed BY HAND:
--
--     supabase functions deploy ical
--
-- .github/workflows/deploy.yml publishes GitHub Pages only, so CI never deploys
-- edge functions. Redeploying is idempotent — when in doubt, redeploy.
--
-- To confirm afterwards, subscribe with a resident token and check that no
-- block 13 On-Call event appears until the block is published.
