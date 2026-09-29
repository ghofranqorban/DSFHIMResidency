-- On-call columns: limit a column to certain blocks.
--
-- Run this in the Supabase SQL editor AFTER add_oncall_slots.sql.
-- Safe to run twice.
--
-- scope_blocks holds block NUMBERS (1..13), not dates, so a column pinned to Block 5 means
-- Block 5 in any academic year. NULL or an empty array means the column runs in every block,
-- which is what every existing column becomes -- so nothing changes until a scheduler says so.

alter table public.oncall_slots
  add column if not exists scope_blocks int[];

comment on column public.oncall_slots.scope_blocks is
  'Block numbers this column appears in. NULL/empty = every block.';

-- Existing rows keep NULL, i.e. every block. Stated explicitly so a re-run is a no-op rather
-- than a surprise.
update public.oncall_slots set scope_blocks = null where scope_blocks = '{}';

-- Check: every column and where it now runs.
select slot_key,
       label,
       group_key,
       coalesce(array_to_string(scope_blocks, ','), 'all blocks') as runs_in,
       active
from public.oncall_slots
order by sort_order, slot_index;
