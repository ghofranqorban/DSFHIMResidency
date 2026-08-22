-- DSFH Residency Portal — Calendar custom events
-- Run in: Supabase → SQL Editor → New query. Safe to re-run.
--
-- Backs the "+" button on the Calendar month grid. PD / chief add things the rota
-- does not know about (Quiz Day, mock exam, a research meeting) either as a whole-day
-- highlight or a timed period, and publish them to everyone or to named residents.
-- These rows are also read by the `ical` edge function, so they reach phones.

create table if not exists calendar_events (
  id            uuid primary key default gen_random_uuid(),
  academic_year integer,
  event_date    date not null,
  title         text not null,
  all_day       boolean not null default true,
  start_time    time,
  end_time      time,
  color         text not null default '#c96a4a',
  -- targeting: target_all overrides the id list, same shape as announcements
  target_all    boolean not null default true,
  target_resident_ids bigint[] not null default '{}',
  created_by    uuid references auth.users(id) on delete set null,
  created_at    timestamptz default now(),
  -- a timed event must actually carry a time; a whole-day one must not
  constraint cal_ev_times check (
    (all_day and start_time is null and end_time is null)
    or (not all_day and start_time is not null and end_time is not null and end_time > start_time)
  )
);

alter table calendar_events enable row level security;

drop policy if exists cal_ev_all on calendar_events;
drop policy if exists cal_ev_select on calendar_events;

-- PD / chief (/ deputy_pd, per is_pd_or_chief()): create, edit, delete
create policy cal_ev_all on calendar_events for all to authenticated
  using (is_pd_or_chief())
  with check (is_pd_or_chief());

-- Everyone else: read-only, and only what is aimed at them
create policy cal_ev_select on calendar_events for select to authenticated using (
  is_pd_or_chief()
  or target_all = true
  or app_resident_id() = any (target_resident_ids)
);

create index if not exists cal_ev_date_idx on calendar_events(event_date);
create index if not exists cal_ev_year_idx on calendar_events(academic_year);

-- ── Verify ───────────────────────────────────────────────────────────────────
select column_name, data_type, is_nullable, column_default
from information_schema.columns
where table_name = 'calendar_events'
order by ordinal_position;

select policyname, cmd from pg_policies
where tablename = 'calendar_events'
order by policyname;
-- Expect two policies: cal_ev_all (ALL) and cal_ev_select (SELECT).
