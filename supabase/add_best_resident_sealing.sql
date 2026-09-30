-- ============================================================================
-- Stars / Best Resident: keep the result secret until it is announced.
--
-- Until now every signed-in account could read every vote and every winner
-- straight from the database, whatever the portal chose to show. Hiding the
-- rankings on screen did not hide the data behind them. This closes that.
--
-- After this file:
--   * A vote can be read by the person who cast it and by NOBODY else, the PD
--     included. The voting form promises "no one sees who you voted for", and
--     this is what makes it true. Everything the portal needs from other
--     people's votes is a COUNT, and best_resident_tally() gives counts only.
--   * Locked winners cannot be read by anyone but the PD and deputy until the
--     announcement time. The names do not reach a resident's browser at all.
--   * A vote is accepted only while voting is open, checked here and not just
--     on the page.
--   * best_resident_status() gives the portal the state of each quarter, with
--     the winners blanked while sealed, and the SERVER's time, so the reveal
--     no longer depends on the clock of whoever is looking.
--
-- Changes no data. Safe to re-run.
-- ============================================================================

-- ── 1. What is there now. Read-only. ────────────────────────────────────────
select tablename, policyname, cmd, qual as using_rule, with_check
from pg_policies
where schemaname = 'public'
  and tablename in ('best_resident_votes', 'best_resident_winners')
order by tablename, policyname;

-- ── 2. Must exist before anything else is touched ───────────────────────────
do $$
begin
  if to_regprocedure('public.app_role()') is null then
    raise exception 'app_role() does not exist in this database. Nothing has been changed. Send this message back.';
  end if;
  if to_regclass('public.best_resident_votes') is null or to_regclass('public.best_resident_winners') is null then
    raise exception 'The best_resident tables were not found. Nothing has been changed.';
  end if;
end $$;

-- ── 3. Helpers ──────────────────────────────────────────────────────────────
-- The two roles that run the award. Everyone else, consultants and observers
-- included, waits for the announcement like the residents do.
create or replace function br_is_lead()
returns boolean
language sql stable security definer set search_path = public
as $$
  select coalesce(app_role() in ('pd', 'deputy_pd'), false);
$$;

-- The first moment AFTER a quarter, Riyadh time. Quarters follow the academic
-- year: Q1 Oct-Dec, Q2 Jan-Mar, Q3 Apr-Jun, Q4 Jul-Sep.
create or replace function br_quarter_end(ay int, q int)
returns timestamptz
language sql stable
as $$
  select ((case q
            when 1 then make_date(ay,     12, 31)
            when 2 then make_date(ay + 1,  3, 31)
            when 3 then make_date(ay + 1,  6, 30)
            else        make_date(ay + 1,  9, 30)
          end) + 1)::timestamp at time zone 'Asia/Riyadh';
$$;

-- Whether a quarter's vote COUNTS are open to everyone: it is still running, or
-- its winners have been revealed.
create or replace function br_public(ay int, q int)
returns boolean
language sql stable security definer set search_path = public
as $$
  select now() < br_quarter_end(ay, q)
      or exists (select 1 from best_resident_winners w
                  where w.academic_year = ay and w.quarter = q
                    and coalesce(w.announced, false)
                    and (w.announced_at is null or w.announced_at <= now()));
$$;

-- Whether a vote for this quarter may be cast right now.
create or replace function br_voting_open(ay int, q int)
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (select 1 from best_resident_winners w
                  where w.academic_year = ay and w.quarter = q
                    and coalesce(w.voting_open, false)
                    and not coalesce(w.announced, false)
                    and (w.voting_deadline is null or w.voting_deadline > now()));
$$;

-- ── 4. Replace the rules ────────────────────────────────────────────────────
-- Rules on a table are OR-ed together: one leftover "everyone may read"
-- defeats every rule written after it. So ALL existing rules on these two
-- tables are removed, whatever they are called, and the full set is written
-- fresh. It happens inside one transaction, so the tables are never left
-- without rules.
do $$
declare p record;
begin
  for p in
    select tablename, policyname from pg_policies
    where schemaname = 'public'
      and tablename in ('best_resident_votes', 'best_resident_winners')
  loop
    execute format('drop policy %I on public.%I', p.policyname, p.tablename);
  end loop;

  alter table public.best_resident_votes   enable row level security;
  alter table public.best_resident_winners enable row level security;

  -- votes: your own, and only your own. There is deliberately no rule that lets
  -- anyone read, or delete, another person's vote.
  create policy br_votes_read on public.best_resident_votes
    for select to authenticated
    using (profile_id = auth.uid());

  create policy br_votes_cast on public.best_resident_votes
    for insert to authenticated
    with check (profile_id = auth.uid() and br_voting_open(academic_year, quarter));

  create policy br_votes_change on public.best_resident_votes
    for update to authenticated
    using      (profile_id = auth.uid() and br_voting_open(academic_year, quarter))
    with check (profile_id = auth.uid() and br_voting_open(academic_year, quarter));

  -- winners
  create policy br_winners_read on public.best_resident_winners
    for select to authenticated
    using (br_is_lead()
           or not (coalesce(announced, false) and announced_at is not null and announced_at > now()));

  create policy br_winners_manage on public.best_resident_winners
    for all to authenticated
    using (br_is_lead()) with check (br_is_lead());
end $$;

-- ── 5. What the portal asks for ─────────────────────────────────────────────
-- Every quarter's row, plus the server's time. While winners are sealed their
-- names and scores are blanked for everyone but the PD and deputy; the row
-- itself still comes through, because the countdown needs the announcement time.
create or replace function best_resident_status()
returns jsonb
language sql stable security definer set search_path = public
as $$
  select jsonb_build_object(
    'now',  now(),
    'rows', coalesce(jsonb_agg(
      case
        when br_is_lead()
          or not (coalesce(w.announced, false) and w.announced_at is not null and w.announced_at > now())
        then to_jsonb(w)
        else to_jsonb(w) || jsonb_build_object(
               'senior_resident_id', null, 'junior_resident_id', null,
               'senior_score',       null, 'junior_score',       null)
      end
      order by w.academic_year, w.quarter), '[]'::jsonb))
  from best_resident_winners w;
$$;

revoke all on function best_resident_status() from public;
grant execute on function best_resident_status() to authenticated;

-- How many votes each candidate has. Counts, never voters: nothing this returns
-- says who cast a vote. The number of people who have voted is given to anyone;
-- the split between candidates only to the PD and deputy, until the quarter's
-- counts are public.
create or replace function best_resident_tally(ay int, q int)
returns jsonb
language sql stable security definer set search_path = public
as $$
  select jsonb_build_object(
    'academic_year', ay,
    'quarter',       q,
    'total',  (select count(*) from best_resident_votes v
                  where v.academic_year = ay and v.quarter = q),
    'senior', case when br_is_lead() or br_public(ay, q) then coalesce((
                  select jsonb_object_agg(t.rid, t.n) from (
                    select v.voted_senior_id::text as rid, count(*) as n
                    from best_resident_votes v
                    where v.academic_year = ay and v.quarter = q and v.voted_senior_id is not null
                    group by v.voted_senior_id) t), '{}'::jsonb)
                else '{}'::jsonb end,
    'junior', case when br_is_lead() or br_public(ay, q) then coalesce((
                  select jsonb_object_agg(t.rid, t.n) from (
                    select v.voted_junior_id::text as rid, count(*) as n
                    from best_resident_votes v
                    where v.academic_year = ay and v.quarter = q and v.voted_junior_id is not null
                    group by v.voted_junior_id) t), '{}'::jsonb)
                else '{}'::jsonb end);
$$;

revoke all on function best_resident_tally(int, int) from public;
grant execute on function best_resident_tally(int, int) to authenticated;

-- ── 6. Check what you got ───────────────────────────────────────────────────
-- Expect exactly five rules, all starting with br_. Any other name in this list
-- is a leftover: send the list back.
select tablename, policyname, cmd
from pg_policies
where schemaname = 'public'
  and tablename in ('best_resident_votes', 'best_resident_winners')
order by tablename, policyname;
