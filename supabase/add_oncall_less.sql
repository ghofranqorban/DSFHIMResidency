-- ============================================================================
-- Less on-call (reward): one on-call fewer than the block average, per resident
-- per block.
--
-- It is the mirror of oncall_schedule.is_extra. Extra sits on a schedule row
-- because it is a shift that was worked; Less is a shift that was NOT worked,
-- so it has no date and no slot and gets its own table. The PD's rule for
-- earning it: present at every Morning Meeting of the block before — not late,
-- not excused, not away. The portal shows that record to whoever builds the
-- schedule; the tick itself is the scheduler's.
--
-- Who reads: everyone signed in. The mark shows under the resident's name on
-- the published grid for all to see, exactly as the Extra mark does (the PD's
-- decision, 30 Oct 2026). Who writes: the PD, deputy, chief and anyone holding
-- the on-call privilege (oncall_can_edit(), from add_oncall_prefs.sql).
--
-- Run in the Supabase SQL Editor. Safe to re-run.
-- ============================================================================

do $$
begin
  if to_regprocedure('public.oncall_can_edit()') is null then
    raise exception 'oncall_can_edit() does not exist (add_oncall_prefs.sql). Nothing has been changed. Send this message back.';
  end if;
  if to_regprocedure('public.app_resident_id()') is null then
    raise exception 'app_resident_id() does not exist. Nothing has been changed. Send this message back.';
  end if;
end $$;

create table if not exists oncall_less (
  id            bigint generated always as identity primary key,
  academic_year int    not null,
  block_number  int    not null,
  resident_id   bigint not null references residents(id),
  reason        text,
  created_by    uuid,
  created_at    timestamptz not null default now(),
  unique (academic_year, block_number, resident_id)
);

create index if not exists oncall_less_block_idx on oncall_less (academic_year, block_number);

alter table oncall_less enable row level security;

drop policy if exists oncall_less_read   on oncall_less;
drop policy if exists oncall_less_insert on oncall_less;
drop policy if exists oncall_less_update on oncall_less;
drop policy if exists oncall_less_delete on oncall_less;

create policy oncall_less_read on oncall_less
  for select to authenticated
  using ( true );
create policy oncall_less_insert on oncall_less
  for insert to authenticated
  with check ( oncall_can_edit() );
create policy oncall_less_update on oncall_less
  for update to authenticated
  using ( oncall_can_edit() ) with check ( oncall_can_edit() );
-- Saving a block replaces its rows rather than diffing them, so delete is needed.
create policy oncall_less_delete on oncall_less
  for delete to authenticated
  using ( oncall_can_edit() );

-- ── Check ───────────────────────────────────────────────────────────────────
select policyname, cmd, qual as using_rule, with_check
from pg_policies
where schemaname = 'public' and tablename = 'oncall_less'
order by policyname;
