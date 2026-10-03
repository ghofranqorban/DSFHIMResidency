-- ============================================================================
-- Stars / Best Resident: votes from nurses and consultants.
--
-- They have no portal accounts. They vote on a Google Form (one for nurses, one
-- for consultants); a small script on each response sheet sends every vote to
-- the edge function `external-vote`, which writes it here. Nobody but that
-- function writes to this table.
--
-- After this file:
--   * public.best_resident_external_votes holds those votes, one row per person
--     per quarter (a second submission by the same name replaces the first).
--   * Only the PD can read the rows (who voted for whom, from which group).
--     Residents and everyone else get COUNTS only, through best_resident_tally().
--   * best_resident_tally() now counts resident, nurse and consultant votes
--     together, one vote each, and also says how many came from each group.
--
-- Changes no existing data. Safe to re-run. Run in the Supabase SQL Editor.
-- ============================================================================

-- ── 1. Must exist before anything else is touched ───────────────────────────
do $$
begin
  if to_regprocedure('public.app_role()') is null
     or to_regprocedure('public.br_is_lead()') is null
     or to_regprocedure('public.br_public(integer,integer)') is null then
    raise exception 'The Stars sealing migration (add_best_resident_sealing.sql) has not been run. Nothing has been changed.';
  end if;
end $$;

-- ── 2. The table ────────────────────────────────────────────────────────────
create table if not exists public.best_resident_external_votes (
  id              uuid primary key default gen_random_uuid(),
  source          text   not null check (source in ('nurse', 'consultant')),
  voter_name      text   not null,          -- as typed on the form
  voter_key       text   not null,          -- lower-case, spaces collapsed: one vote per person
  academic_year   int    not null,
  quarter         int    not null check (quarter between 1 and 4),
  voted_senior_id bigint references public.residents(id) on delete set null,
  voted_junior_id bigint references public.residents(id) on delete set null,
  submitted_at    timestamptz not null default now(),
  unique (source, voter_key, academic_year, quarter)
);

alter table public.best_resident_external_votes enable row level security;

do $$
declare p record;
begin
  for p in select policyname from pg_policies
           where schemaname = 'public' and tablename = 'best_resident_external_votes'
  loop
    execute format('drop policy %I on public.best_resident_external_votes', p.policyname);
  end loop;

  -- Read: the PD, and only the PD. There is NO insert/update/delete rule: the
  -- edge function writes with the service-role key, which bypasses these rules,
  -- and nothing a browser sends can add, change or remove a vote.
  create policy br_external_read on public.best_resident_external_votes
    for select to authenticated
    using (coalesce(app_role() = 'pd', false));
end $$;

-- ── 3. Counting: residents + nurses + consultants, one vote each ────────────
-- Same shape as before ('total', 'senior', 'junior'), plus how many voters came
-- from each group, and each candidate's votes split by group. As before, the
-- split between candidates is given only to the PD and deputy until the
-- quarter's counts are public; the number of voters is given to anyone.
create or replace function best_resident_tally(ay int, q int)
returns jsonb
language sql stable security definer set search_path = public
as $$
  with allv as (
    select 'resident'::text as src, v.voted_senior_id as sid, v.voted_junior_id as jid
      from best_resident_votes v
     where v.academic_year = ay and v.quarter = q
    union all
    select e.source, e.voted_senior_id, e.voted_junior_id
      from best_resident_external_votes e
     where e.academic_year = ay and e.quarter = q
  ),
  shown as (select br_is_lead() or br_public(ay, q) as ok)
  select jsonb_build_object(
    'academic_year', ay,
    'quarter',       q,
    'total',         (select count(*) from allv),
    'by_source',     jsonb_build_object(
                       'resident',   (select count(*) from allv where src = 'resident'),
                       'nurse',      (select count(*) from allv where src = 'nurse'),
                       'consultant', (select count(*) from allv where src = 'consultant')),
    'senior', case when (select ok from shown) then coalesce((
                select jsonb_object_agg(t.rid, t.n) from (
                  select sid::text as rid, count(*) as n from allv
                  where sid is not null group by sid) t), '{}'::jsonb)
              else '{}'::jsonb end,
    'junior', case when (select ok from shown) then coalesce((
                select jsonb_object_agg(t.rid, t.n) from (
                  select jid::text as rid, count(*) as n from allv
                  where jid is not null group by jid) t), '{}'::jsonb)
              else '{}'::jsonb end,
    'senior_by_source', case when (select ok from shown) then coalesce((
                select jsonb_object_agg(t.rid, t.s) from (
                  select sid::text as rid,
                         jsonb_build_object(
                           'resident',   count(*) filter (where src = 'resident'),
                           'nurse',      count(*) filter (where src = 'nurse'),
                           'consultant', count(*) filter (where src = 'consultant')) as s
                  from allv where sid is not null group by sid) t), '{}'::jsonb)
              else '{}'::jsonb end,
    'junior_by_source', case when (select ok from shown) then coalesce((
                select jsonb_object_agg(t.rid, t.s) from (
                  select jid::text as rid,
                         jsonb_build_object(
                           'resident',   count(*) filter (where src = 'resident'),
                           'nurse',      count(*) filter (where src = 'nurse'),
                           'consultant', count(*) filter (where src = 'consultant')) as s
                  from allv where jid is not null group by jid) t), '{}'::jsonb)
              else '{}'::jsonb end);
$$;

revoke all on function best_resident_tally(int, int) from public;
grant execute on function best_resident_tally(int, int) to authenticated;

-- ── 4. Check what you got ───────────────────────────────────────────────────
-- Expect: one row, br_external_read, cmd SELECT. Anything else is a leftover.
select tablename, policyname, cmd
from pg_policies
where schemaname = 'public' and tablename = 'best_resident_external_votes';

-- Expect: total = the number of resident votes so far, nurse and consultant = 0.
select best_resident_tally(2025, 4) -> 'total'     as total,
       best_resident_tally(2025, 4) -> 'by_source' as by_source;
