-- Academic years and portal settings, so the Program Director can set up a year from the portal.
-- Run in the Supabase SQL editor. Idempotent.
--
-- academic_years  one row per year: its start date and the length in weeks of each of its 13 blocks.
--                 The portal turns a row into its block dates, so a new year no longer needs a code
--                 edit. A year with no row keeps the dates built into the portal.
-- portal_settings small key/value table. 'plan_year' says which year the AY Plan module (leave plan,
--                 GIM and R4 windows, chief election) works on. Later Control Centre settings reuse it.
--
-- Read by every signed-in user (the dates are needed everywhere); written by pd and deputy_pd only.

create table if not exists public.academic_years (
  ay          int primary key,                 -- 2026 means AY 2026-27
  start_date  date not null,                   -- first day of block 1, normally a Sunday
  block_weeks smallint[] not null default '{4,4,4,4,4,4,4,4,4,4,4,4,4}',
  note        text,
  updated_at  timestamptz not null default now(),
  updated_by  uuid,
  constraint academic_years_blocks_ck
    check (array_length(block_weeks, 1) = 13 and 0 < all (block_weeks) and 9 > all (block_weeks))
);

create table if not exists public.portal_settings (
  key         text primary key,
  value       jsonb not null,
  updated_at  timestamptz not null default now(),
  updated_by  uuid
);

alter table public.academic_years  enable row level security;
alter table public.portal_settings enable row level security;

drop policy if exists academic_years_read on public.academic_years;
create policy academic_years_read on public.academic_years for select to authenticated using (true);
drop policy if exists academic_years_write on public.academic_years;
create policy academic_years_write on public.academic_years for all to authenticated
  using (coalesce(app_role() in ('pd','deputy_pd'), false))
  with check (coalesce(app_role() in ('pd','deputy_pd'), false));

drop policy if exists portal_settings_read on public.portal_settings;
create policy portal_settings_read on public.portal_settings for select to authenticated using (true);
drop policy if exists portal_settings_write on public.portal_settings;
create policy portal_settings_write on public.portal_settings for all to authenticated
  using (coalesce(app_role() in ('pd','deputy_pd'), false))
  with check (coalesce(app_role() in ('pd','deputy_pd'), false));

-- Today's year, exactly as the portal already has it built in, so nothing changes until you edit it.
insert into public.academic_years (ay, start_date) values (2026, '2026-10-04') on conflict (ay) do nothing;
insert into public.portal_settings (key, value) values ('plan_year', '{"ay": 2026}') on conflict (key) do nothing;

-- Check: two rules per table, the 2026 year, and the planning year.
select tablename, policyname, cmd from pg_policies
 where schemaname = 'public' and tablename in ('academic_years', 'portal_settings') order by tablename, policyname;
select ay, start_date, block_weeks from public.academic_years order by ay;
select key, value from public.portal_settings;
