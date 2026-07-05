-- DSFH Residency Portal — Announcements / Deadlines table
-- Run in: Supabase → SQL Editor → New query

create table if not exists announcements (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  description text,
  deadline_date date,
  category    text default 'task',
  -- targeting: target_all overrides level/resident
  target_all  boolean default true,
  target_level text,               -- 'R1' | 'R2' | 'R3' | 'R4'
  target_resident_id integer references residents(id) on delete cascade,
  academic_year integer,
  created_by  uuid references auth.users(id) on delete set null,
  created_at  timestamptz default now()
);

alter table announcements enable row level security;

-- PD / chief / deputy_pd: full access
create policy ann_all on announcements for all to authenticated
  using (is_pd_or_chief())
  with check (is_pd_or_chief());

-- Residents + consultants: read what targets them
create policy ann_select on announcements for select to authenticated using (
  is_pd_or_chief()
  or target_all = true
  or target_resident_id = app_resident_id()
  or (
    target_level is not null
    and target_level = (select level from residents where id = app_resident_id())
  )
);

-- Index for fast lookups
create index if not exists ann_year_idx on announcements(academic_year);
create index if not exists ann_deadline_idx on announcements(deadline_date);
