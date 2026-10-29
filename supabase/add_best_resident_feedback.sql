-- ============================================================================
-- Stars / Best Resident: free-text feedback from the nurses' and consultants' forms.
--
-- The vote pipeline (add_best_resident_external_votes.sql) carried only the two names. The forms
-- also ask for feedback about the residents; from now on the response-sheet script sends that
-- text with the vote and the edge function `external-vote` writes it here, one row per person per
-- quarter (a second submission by the same name replaces the first). Kept apart from the votes
-- table so a comment is never counted as a vote and so comments exported by hand can be loaded
-- without inventing voters.
--
-- Only the PD can read it. Nothing a browser sends can write: the function uses the service role.
-- Safe to re-run. Run in the Supabase SQL Editor, the whole file at once.
--
-- Backfill of earlier quarters: the exported comments are personal text and stay OUT of this
-- public repository. The insert statements live beside the export, in the private 25-26 folder
-- (backfill_best_resident_feedback_Q4_2025-26.sql); run that file after this one.
-- ============================================================================

create table if not exists public.best_resident_feedback (
  id             uuid primary key default gen_random_uuid(),
  source         text not null check (source in ('nurse','consultant')),
  voter_name     text not null,            -- as typed on the form, or "(anonymous)"
  voter_key      text not null,            -- same key as the vote row, so the two line up
  academic_year  int  not null,
  quarter        int  not null check (quarter between 1 and 4),
  body           text not null,
  submitted_at   timestamptz not null default now(),
  unique (source, voter_key, academic_year, quarter)
);

alter table public.best_resident_feedback enable row level security;

drop policy if exists br_feedback_read on public.best_resident_feedback;
create policy br_feedback_read on public.best_resident_feedback
  for select to authenticated
  using (coalesce(app_role() = 'pd', false));

grant select on public.best_resident_feedback to authenticated;

-- Expected: one policy, br_feedback_read.
select polname from pg_policy where polrelid = 'public.best_resident_feedback'::regclass;
