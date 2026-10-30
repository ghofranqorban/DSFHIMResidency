-- ============================================================================
-- Extra on-call due (penalty), beside the Less on-call reward.
--
-- The same per-resident, per-block table now carries a kind: 'less' is one
-- on-call fewer (the reward, present at every Morning Meeting of the block
-- before); 'extra' is one on-call more (the penalty, absent from more than N
-- Morning Meetings of the block before, N set in Control Centre > Leave and
-- rules, 5 by default). A resident holds at most one mark per block, so the
-- existing unique key (year, block, resident) stays and the two are exclusive.
--
-- The per-shift flag oncall_schedule.is_extra is untouched: it still marks
-- the one shift that is the penalty, which is what Statistics count.
--
-- Run in the Supabase SQL Editor after add_oncall_less.sql. Safe to re-run.
-- ============================================================================

alter table public.oncall_less
  add column if not exists kind text not null default 'less';

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'oncall_less_kind_check') then
    alter table public.oncall_less
      add constraint oncall_less_kind_check check (kind in ('less','extra'));
  end if;
end $$;

-- ── Check ───────────────────────────────────────────────────────────────────
select column_name, data_type, column_default
from information_schema.columns
where table_schema = 'public' and table_name = 'oncall_less'
order by ordinal_position;
