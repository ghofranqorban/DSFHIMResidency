-- ============================================================================
-- On-call preferences: a resident's avoid-days are theirs and the schedulers'.
--
-- Until now every signed-in account could read every resident's picks. The
-- portal only ever showed them to the people building the schedule, but the
-- rows still reached every browser. This closes that in the database:
--
--   * A resident reads their own picks.
--   * The PD, deputy, chief and anyone holding the on-call privilege read all
--     of them (oncall_can_edit(), the same test the write rules already use).
--   * Nobody else reads any.
--
-- The survey window (oncall_prefs_status) stays readable by all: it only says
-- whether the survey is open. Changes no data. Safe to re-run.
-- ============================================================================

-- ── 1. What is there now. Read-only. ────────────────────────────────────────
select policyname, cmd, qual as using_rule
from pg_policies
where schemaname = 'public' and tablename = 'oncall_prefs'
order by policyname;

-- ── 2. The helpers this depends on must exist ───────────────────────────────
do $$
begin
  if to_regprocedure('public.oncall_can_edit()') is null then
    raise exception 'oncall_can_edit() does not exist. Nothing has been changed. Send this message back.';
  end if;
  if to_regprocedure('public.app_resident_id()') is null then
    raise exception 'app_resident_id() does not exist. Nothing has been changed. Send this message back.';
  end if;
end $$;

-- ── 3. Replace every READ rule on the table ─────────────────────────────────
-- Rules OR together, so any leftover "everyone may read" would defeat the new
-- one. All SELECT rules go, whatever they are called; the write rules stay.
do $$
declare p record;
begin
  for p in
    select policyname from pg_policies
    where schemaname = 'public' and tablename = 'oncall_prefs' and cmd = 'SELECT'
  loop
    execute format('drop policy %I on public.oncall_prefs', p.policyname);
  end loop;

  alter table public.oncall_prefs enable row level security;

  create policy oncall_prefs_read on public.oncall_prefs
    for select to authenticated
    using (resident_id = app_resident_id() or oncall_can_edit());
end $$;

-- ── 4. Check what you got ───────────────────────────────────────────────────
-- Expect one SELECT rule, oncall_prefs_read, beside the existing write rules.
select policyname, cmd, qual as using_rule
from pg_policies
where schemaname = 'public' and tablename = 'oncall_prefs'
order by cmd, policyname;
