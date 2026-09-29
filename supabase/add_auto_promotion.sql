-- ============================================================================
-- October promotion, run by the database itself.
--
-- SCFHS moves every resident up a level on 1 October. Until now that waited for
-- the PD to open a review and press Confirm. This makes it happen at midnight
-- on its own:
--
--   R4  -> graduated (active = false)
--   R3  -> R4,  R2 -> R3,  R1 -> R2
--   the cohort that STARTS this October is left alone: it already holds R1
--
-- Three parts:
--   1. A PREVIEW of who would move. Changes nothing. Read it before going on.
--   2. The function run_october_promotion().
--   3. The schedule that calls it at 00:00 Riyadh time on 1 October each year.
--
-- It can only ever run once per year: promotion_log holds one row per year, and
-- the function stops if this year's row is already there. Before 1 October it
-- does nothing at all. Safe to re-run this file.
-- ============================================================================

-- ── 1. PREVIEW — who moves on 1 October. Read-only. ─────────────────────────
select
  name,
  level                                         as level_now,
  year_started,
  case
    when coalesce(year_started,0) >= extract(year from (now() at time zone 'Asia/Riyadh'))::int
                       then 'stays ' || level || ' (new intake)'
    when level = 'R4'  then 'GRADUATES'
    when level = 'R3'  then 'R4'
    when level = 'R2'  then 'R3'
    when level = 'R1'  then 'R2'
  end                                           as on_1_october
from residents
where active
order by level desc, name;

-- ── 2. The function ─────────────────────────────────────────────────────────
-- The live promotion_log is NOT the table in add_promotion_log.sql. Checked
-- against the database on 30 Sep 2026, it is:
--     id bigint not null · academic_year integer not null · executed_by uuid
--     executed_at timestamptz default now() · details jsonb
-- The first version of this file wrote to promoted_by / changes, which do not
-- exist, and would have failed at midnight. Everything below uses the live names.

-- id must fill itself in. If it is neither an identity column nor defaulted,
-- give it a sequence, or every insert fails on the NOT NULL.
do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'promotion_log' and column_name = 'id'
      and (is_identity = 'YES' or column_default is not null)
  ) then
    create sequence if not exists promotion_log_id_seq owned by promotion_log.id;
    perform setval('promotion_log_id_seq', coalesce((select max(id) from promotion_log), 0) + 1, false);
    alter table promotion_log alter column id set default nextval('promotion_log_id_seq');
  end if;
end $$;

-- One row per year is what makes a second run impossible, so make sure the
-- table really enforces it. The live table has been edited by hand before.
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conrelid = 'promotion_log'::regclass and contype in ('u','p')
      and pg_get_constraintdef(oid) ilike '%(academic_year)%'
  ) then
    alter table promotion_log add constraint promotion_log_academic_year_key unique (academic_year);
  end if;
end $$;

create or replace function run_october_promotion()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  today     date := (now() at time zone 'Asia/Riyadh')::date;
  y         int  := extract(year from today)::int;
  changes   jsonb;
  n_up      int;
  n_out     int;
begin
  -- Levels belong to the year opening this October; nothing moves before the 1st.
  if extract(month from today) < 10 then
    return jsonb_build_object('ran', false, 'reason', 'before 1 October');
  end if;

  -- The midnight job and the first person to open the portal can arrive together.
  perform pg_advisory_xact_lock(hashtext('run_october_promotion'));
  if exists (select 1 from promotion_log where academic_year = y) then
    return jsonb_build_object('ran', false, 'reason', 'already promoted');
  end if;

  -- Written down before anything changes, in the shape the portal already logs.
  select coalesce(jsonb_agg(jsonb_build_object(
           'id', id, 'name', name, 'from', level,
           'to', case level when 'R4' then 'archived' when 'R3' then 'R4'
                            when 'R2' then 'R3' else 'R2' end)
           order by level desc, name), '[]'::jsonb)
    into changes
    from residents
   where active and level in ('R1','R2','R3','R4') and coalesce(year_started,0) < y;

  -- Graduates first. The other way round, the new R4s would be archived with them.
  update residents set active = false
   where active and level = 'R4' and coalesce(year_started,0) < y;
  get diagnostics n_out = row_count;

  -- One statement, so each row is read at its old level and moves exactly one step.
  update residents
     set level = case level when 'R3' then 'R4' when 'R2' then 'R3' when 'R1' then 'R2' end
   where active and level in ('R1','R2','R3') and coalesce(year_started,0) < y;
  get diagnostics n_up = row_count;

  insert into promotion_log (academic_year, executed_by, details) values (y, null, changes);

  return jsonb_build_object('ran', true, 'year', y, 'promoted', n_up, 'archived', n_out);
end $$;

revoke all on function run_october_promotion() from public;
grant execute on function run_october_promotion() to authenticated;

-- ── 3. The schedule ─────────────────────────────────────────────────────────
-- pg_cron works in UTC. 21:00 UTC on 30 September is 00:00 on 1 October in
-- Riyadh. A second job retries nightly for the first week of October, which is
-- harmless: once the year has its row the function returns without writing.
-- If pg_cron cannot be switched on here, this prints a notice instead of
-- failing, and the portal runs the promotion the first time anyone signs in.
do $$
begin
  create extension if not exists pg_cron;
  perform cron.unschedule(jobid) from cron.job
   where jobname in ('october-promotion','october-promotion-retry');
  perform cron.schedule('october-promotion',       '0 21 30 9 *',
                        'select public.run_october_promotion()');
  perform cron.schedule('october-promotion-retry', '0 21 1-7 10 *',
                        'select public.run_october_promotion()');
  raise notice 'Scheduled: the promotion runs at 00:00 Riyadh time on 1 October.';
exception when others then
  raise notice 'pg_cron is not available (%). The portal will run the promotion at the first sign-in on or after 1 October instead.', sqlerrm;
end $$;

-- ── 4. Rehearse the write ───────────────────────────────────────────────────
-- The function refuses to run before 1 October, so it cannot be tried out for
-- real today. This makes the very same insert and takes it straight back. If
-- the table would reject tonight's row, this file stops HERE with the reason,
-- instead of the promotion failing at midnight with nobody watching.
do $$
begin
  begin
    insert into promotion_log (academic_year, executed_by, details) values (1999, null, '[]'::jsonb);
    raise exception 'rehearsal-ok';
  exception when others then
    if sqlerrm <> 'rehearsal-ok' then
      raise exception 'promotion_log cannot take the promotion row: %', sqlerrm;
    end if;
  end;
end $$;

-- ── 5. Check what you got ───────────────────────────────────────────────────
select
  true                                                                    as log_write_rehearsed,
  exists (select 1 from pg_proc where proname = 'run_october_promotion') as function_installed,
  to_regclass('cron.job') is not null                                     as scheduler_available,
  exists (select 1 from promotion_log
           where academic_year = extract(year from (now() at time zone 'Asia/Riyadh'))::int)
                                                                          as already_promoted_this_year;
