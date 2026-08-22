-- ============================================================
-- Master Rota Builder — draft tables + widened `rotations`.
--
-- The builder never writes `rotations` directly. It writes a DRAFT into
-- `rota_plan`, one block at a time, and only "Push Live" copies a block's
-- rows into `rotations`. That keeps the live rota clean while the plan is
-- still churning (incoming R1s, leave decisions, chief edits).
--
-- Run in: Supabase > SQL Editor > New query. Safe to re-run.
--
-- Part 1 widens `rotations` so a pushed block can round-trip losslessly.
-- Part 2 creates the draft tables.
-- Part 3 is READ-ONLY verification — paste the grid back.
-- ============================================================

begin;

-- ============================================================
-- PART 1 — widen `rotations` for week-level splits
-- ============================================================
-- Today: segment is capped at 2 and weeks at 4, and there is no record of
-- WHERE in the block a segment sits. A 2+2 split is unambiguous, but 1+3 and
-- 3+1 are not, and block 13 of AY 2025-26 is 5 weeks long.
--
-- `week_start` makes a segment a half-open interval [week_start, week_start+weeks).
-- A whole block is segment 1, week_start 1, weeks 4 — which is what every
-- existing unsplit row already means, so the backfill is a no-op for them.

alter table rotations add column if not exists week_start int not null default 1;

do $$
begin
  -- segment 1..4: a block can be cut into at most four one-week pieces.
  if exists (select 1 from pg_constraint
             where conrelid = 'rotations'::regclass and conname = 'rotations_segment_check') then
    alter table rotations drop constraint rotations_segment_check;
  end if;
  alter table rotations add constraint rotations_segment_check check (segment between 1 and 4);

  -- weeks 1..5: block 13 of AY 2025-26 runs 5 weeks (BLOCK_WEEKS_OVERRIDE).
  if exists (select 1 from pg_constraint
             where conrelid = 'rotations'::regclass and conname = 'rotations_weeks_check') then
    alter table rotations drop constraint rotations_weeks_check;
  end if;
  alter table rotations add constraint rotations_weeks_check check (weeks between 1 and 5);

  if not exists (select 1 from pg_constraint
                 where conrelid = 'rotations'::regclass and conname = 'rotations_week_span_check') then
    -- Outer bound only. The real block length varies by year, so the exact
    -- ceiling is enforced in the UI, not here.
    alter table rotations add constraint rotations_week_span_check
      check (week_start between 1 and 5 and week_start + weeks <= 6);
  end if;
end $$;

-- Backfill week_start. Segment 1 always starts at week 1. Every historical
-- split in the 676 imported rows (AY 2021-22 … 2024-25) is 2+2, so segment 2
-- starts at week 3. Part 3 lists any row where that assumption does not hold
-- rather than guessing — do not blind-fix those, they need eyes.
update rotations set week_start = 1 where segment = 1 and week_start is distinct from 1;
update rotations set week_start = 3 where segment = 2 and week_start is distinct from 3;

-- ============================================================
-- PART 2 — the draft tables
-- ============================================================

create table if not exists public.rota_plan (
  id            bigint generated always as identity primary key,
  resident_id   bigint not null references residents(id) on delete cascade,
  academic_year int    not null,
  block_number  int    not null check (block_number between 1 and 13),
  segment       int    not null default 1 check (segment between 1 and 4),
  week_start    int    not null default 1,
  weeks         int    not null default 4 check (weeks between 1 and 5),
  rotation_name text   not null default '',
  leave_weeks   int    not null default 0 check (leave_weeks between 0 and 5),
  leave_position text  not null default 'none',
  note          text,
  updated_by    uuid   references auth.users(id) on delete set null,
  updated_at    timestamptz not null default now(),
  constraint rota_plan_block_segment_key unique (resident_id, academic_year, block_number, segment),
  constraint rota_plan_week_span_check check (week_start between 1 and 5 and week_start + weeks <= 6)
);

create index if not exists rota_plan_year_block_idx on public.rota_plan (academic_year, block_number);
create index if not exists rota_plan_resident_year_idx on public.rota_plan (resident_id, academic_year);

-- One status row per (year, block). Publishing Block 1 on its own is just
-- this row moving to 'published' — nothing about block 2 changes.
--   draft     — chiefs are still laying it out
--   review    — chiefs are done, PD has not looked yet
--   approved  — PD signed off, still not visible to residents
--   published — pushed into `rotations`; residents see it
create table if not exists public.rota_plan_block_status (
  academic_year int not null,
  block_number  int not null check (block_number between 1 and 13),
  state         text not null default 'draft'
                  check (state in ('draft','review','approved','published')),
  approved_by   uuid references auth.users(id) on delete set null,
  approved_at   timestamptz,
  published_by  uuid references auth.users(id) on delete set null,
  published_at  timestamptz,
  pushed_at     timestamptz,
  updated_at    timestamptz not null default now(),
  primary key (academic_year, block_number)
);

alter table public.rota_plan enable row level security;
alter table public.rota_plan_block_status enable row level security;

-- ── who can do what ─────────────────────────────────────────
-- Build  = is_pd_or_chief() OR has_priv('plan_rota')  (Abdullah Farid, Deema
--          Bakhashab hold the privilege; neither has a chief role)
-- Approve/publish = PD side only.
--
-- Residents are NOT given read access to the draft. They see the rota through
-- `rotations`, which only receives rows at Push Live — so an unfinished plan
-- cannot leak.

create or replace function can_build_rota() returns boolean
language sql stable as $$
  select is_pd_or_chief() or has_priv('plan_rota');
$$;

create or replace function can_approve_rota() returns boolean
language sql stable as $$
  select app_role() in ('pd','deputy_pd');
$$;

drop policy if exists rota_plan_select on public.rota_plan;
create policy rota_plan_select on public.rota_plan
  for select to authenticated using (can_build_rota());

-- Builders may only touch blocks that are still draft/review. Once the PD
-- approves a block it freezes, and only the PD can move it back.
drop policy if exists rota_plan_build on public.rota_plan;
create policy rota_plan_build on public.rota_plan
  for all to authenticated
  using (
    can_build_rota() and coalesce(
      (select s.state from public.rota_plan_block_status s
        where s.academic_year = rota_plan.academic_year
          and s.block_number  = rota_plan.block_number), 'draft') in ('draft','review')
  )
  with check (
    can_build_rota() and coalesce(
      (select s.state from public.rota_plan_block_status s
        where s.academic_year = rota_plan.academic_year
          and s.block_number  = rota_plan.block_number), 'draft') in ('draft','review')
  );

drop policy if exists rota_plan_pd on public.rota_plan;
create policy rota_plan_pd on public.rota_plan
  for all to authenticated using (can_approve_rota()) with check (can_approve_rota());

drop policy if exists rota_status_select on public.rota_plan_block_status;
create policy rota_status_select on public.rota_plan_block_status
  for select to authenticated using (can_build_rota());

-- A builder can hand a block up for review, or pull it back to draft. They
-- cannot approve or publish it.
drop policy if exists rota_status_build on public.rota_plan_block_status;
create policy rota_status_build on public.rota_plan_block_status
  for all to authenticated
  using (can_build_rota() and state in ('draft','review'))
  with check (can_build_rota() and state in ('draft','review'));

drop policy if exists rota_status_pd on public.rota_plan_block_status;
create policy rota_status_pd on public.rota_plan_block_status
  for all to authenticated using (can_approve_rota()) with check (can_approve_rota());

commit;

-- ============================================================
-- PART 3 — VERIFY (read-only). Select all, Run, paste the grid back.
-- ============================================================
select '1. rotations cols' as section,
       column_name        as detail,
       coalesce(column_default,'-') as extra,
       'INFO' as result
from information_schema.columns
where table_name = 'rotations' and column_name in ('segment','weeks','week_start')

union all

select '2. rotations checks', conname, pg_get_constraintdef(oid), 'INFO'
from pg_constraint
where conrelid = 'rotations'::regclass
  and conname in ('rotations_segment_check','rotations_weeks_check','rotations_week_span_check')

union all

-- Any split block whose segments do not tile the block cleanly. Expect ZERO
-- rows. Anything here is the `saveRotaCells()` weeks bug: the UI never wrote
-- `weeks`, so a 2-week segment was stored as 4.
select '3. bad splits',
       'resident ' || resident_id || ' AY' || academic_year || ' blk' || block_number,
       'segments=' || count(*) || ' weeks_sum=' || sum(weeks),
       'REVIEW - segments do not tile the block'
from rotations
group by resident_id, academic_year, block_number
having count(*) > 1
   and sum(weeks) <> case when academic_year = 2025 and block_number = 13 then 5 else 4 end

union all

select '4. new tables',
       c.relname,
       (select count(*)::text || ' policies' from pg_policies p where p.tablename = c.relname),
       case when c.relrowsecurity then 'OK - RLS on' else 'PROBLEM - RLS off' end
from pg_class c
where c.relname in ('rota_plan','rota_plan_block_status')

union all

select '5. plan rows', count(*)::text, '', 'OK - expect 0 on first run'
from public.rota_plan

order by section, detail;
