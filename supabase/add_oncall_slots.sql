-- ============================================================================
-- On-call schedule: make the COLUMN SET data instead of code.
--
-- Two things happen here:
--   1. oncall_schedule.slot_key is released from its CHECK constraint. That
--      constraint named the six original columns, so any column added from the
--      editor would have been rejected on first save.
--   2. A new oncall_slots table describes the columns of the grid.
--
-- A row is one SLOT (one assignable box on one day). Slots that share a
-- group_key are drawn under a single heading, stacked, numbered by slot_index.
-- That is how "CTU Cover A" holds two people on the same Friday while still
-- being one column.
--
-- The existing slot_keys are reused verbatim (er_medical, bldg1, bldg2,
-- consult, ctu1, ctu2) so every historical assignment keeps resolving. Only
-- the genuinely new boxes get new keys.
--
-- Safe to re-run.
-- ============================================================================

-- ── 1. Release the slot_key CHECK ───────────────────────────────────────────
-- Named constraint from add_oncall_schedule.sql. Dropped by name if present,
-- then swept for any differently-named CHECK mentioning slot_key, because this
-- table has been migrated by hand in the SQL editor before.
alter table oncall_schedule drop constraint if exists oncall_slot_key_check;

do $$
declare c record;
begin
  for c in
    select con.conname
    from pg_constraint con
    where con.conrelid = 'oncall_schedule'::regclass
      and con.contype  = 'c'
      and pg_get_constraintdef(con.oid) ilike '%slot_key%'
  loop
    execute format('alter table oncall_schedule drop constraint %I', c.conname);
    raise notice 'dropped leftover slot_key check: %', c.conname;
  end loop;
end $$;

-- ── 2. The column definition table ──────────────────────────────────────────
create table if not exists oncall_slots (
  id          bigserial primary key,
  slot_key    text    not null unique,        -- joins to oncall_schedule.slot_key
  label       text    not null,               -- the column heading
  group_key   text    not null,               -- slots sharing this = one column
  slot_index  int     not null default 1,     -- position within the column (1,2,…)
  hours_mode  text    not null default 'oncall'   check (hours_mode in ('oncall','day')),
  days_mode   text    not null default 'all'      check (days_mode  in ('all','weekend')),
  sort_order  int     not null default 0,
  active      boolean not null default true,
  created_at  timestamptz default now()
);

create index if not exists oncall_slots_group_idx on oncall_slots (group_key, slot_index);

-- ── 3. Seed: today's six columns, plus a 4th Floor and a 2nd box on each CTU ─
-- hours_mode 'day'    = 08:00-16:00 always (CTU day cover)
-- hours_mode 'oncall' = 08:00-22:00 weekend, 16:00-22:00 weekday
-- days_mode  'weekend'= column only exists on Fri/Sat
insert into oncall_slots (slot_key, label, group_key, slot_index, hours_mode, days_mode, sort_order) values
  ('er_medical', 'ER Medical Oncall', 'er_medical', 1, 'oncall', 'all',     10),
  ('bldg1',      'Floor Oncall',      'bldg1',      1, 'oncall', 'all',     20),
  ('bldg2',      'Floor Oncall',      'bldg2',      1, 'oncall', 'all',     30),
  ('consult',    'Floor Oncall',      'consult',    1, 'oncall', 'all',     40),
  ('floor4',     'Floor Oncall',      'floor4',     1, 'oncall', 'all',     50),
  ('ctu1',       'CTU Cover A',       'ctu_a',      1, 'day',    'weekend', 60),
  ('ctu_a2',     'CTU Cover A',       'ctu_a',      2, 'day',    'weekend', 61),
  ('ctu2',       'CTU Cover B',       'ctu_b',      1, 'day',    'weekend', 70),
  ('ctu_b2',     'CTU Cover B',       'ctu_b',      2, 'day',    'weekend', 71)
on conflict (slot_key) do nothing;

-- ── 4. RLS ──────────────────────────────────────────────────────────────────
-- Everyone signed in reads the columns (residents need the headings to read the
-- grid at all). Only the people who can edit the on-call schedule may change
-- them, so this reuses oncall_can_edit() rather than is_pd_or_chief(), which
-- would drop deputy_pd.
alter table oncall_slots enable row level security;

drop policy if exists oncall_slots_read  on oncall_slots;
drop policy if exists oncall_slots_write on oncall_slots;

create policy oncall_slots_read on oncall_slots
  for select to authenticated using (true);

create policy oncall_slots_write on oncall_slots
  for all to authenticated
  using (oncall_can_edit()) with check (oncall_can_edit());

-- ── 5. Check what you got ───────────────────────────────────────────────────
select group_key, label, count(*) as slots, min(days_mode) as days, min(hours_mode) as hours
from oncall_slots where active
group by group_key, label, sort_order
order by sort_order;
