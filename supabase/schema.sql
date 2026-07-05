-- DSFH Residency Portal — Phase 0 schema
-- Run this once in the Supabase SQL editor (Project > SQL Editor > New query).
-- Safe to re-run: uses IF NOT EXISTS / CREATE OR REPLACE where possible.

-- ─── CORE TABLES ────────────────────────────────────────────────────────────

create table if not exists consultants (
  id bigint generated always as identity primary key,
  name text not null,
  username text unique not null,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists residents (
  id bigint generated always as identity primary key,
  name text not null,
  username text unique not null,
  level text not null check (level in ('R1','R2','R3','R4')),
  photo_initials text,
  mentor_id bigint references consultants(id) on delete set null,
  active boolean not null default true,
  year_started int not null,           -- academic year (e.g. 2025 for the 2025-26 cycle) they started as R1
  archived_at timestamptz,             -- set when promoted out of R4 / withdrawn
  created_at timestamptz not null default now()
);

-- Links a Supabase Auth user to an app role + identity record.
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  role text not null check (role in ('pd','chief','consultant','resident')),
  display_name text not null,
  resident_id bigint references residents(id) on delete cascade,
  consultant_id bigint references consultants(id) on delete cascade,
  created_at timestamptz not null default now()
);

-- ─── HELPER FUNCTIONS (used by RLS policies) ────────────────────────────────

create or replace function app_role() returns text
language sql stable security definer set search_path = public as $$
  select role from profiles where id = auth.uid();
$$;

create or replace function app_resident_id() returns bigint
language sql stable security definer set search_path = public as $$
  select resident_id from profiles where id = auth.uid();
$$;

create or replace function app_consultant_id() returns bigint
language sql stable security definer set search_path = public as $$
  select consultant_id from profiles where id = auth.uid();
$$;

create or replace function is_pd_or_chief() returns boolean
language sql stable as $$
  select app_role() in ('pd','chief');
$$;

-- ─── PRIVILEGES ──────────────────────────────────────────────────────────────

create table if not exists account_privileges (
  id bigint generated always as identity primary key,
  profile_id uuid not null references profiles(id) on delete cascade,
  privilege_key text not null check (privilege_key in (
    'edit_quiz_marks','edit_mm_attendance','edit_teach_attendance','edit_kpi_notes'
  )),
  granted_by uuid references profiles(id),
  granted_at timestamptz not null default now(),
  unique(profile_id, privilege_key)
);

-- ─── MENTOR NOTES (areas of concern / improvement / comments) ──────────────

create table if not exists mentor_notes (
  id bigint generated always as identity primary key,
  resident_id bigint not null references residents(id) on delete cascade,
  mentor_id bigint not null references consultants(id) on delete cascade,
  type text not null check (type in ('concern','improvement','comment')),
  body text not null,
  created_at timestamptz not null default now()
);

-- ─── COUNSELING (with countersign workflow) ────────────────────────────────

create table if not exists counseling (
  id bigint generated always as identity primary key,
  resident_id bigint not null references residents(id) on delete cascade,
  date date not null,
  reason text not null,
  details text,
  issued_by uuid references profiles(id),
  recipient_profile_id uuid references profiles(id),
  acknowledged_by uuid references profiles(id),
  acknowledged_at timestamptz,
  created_at timestamptz not null default now()
);

-- Security-definer function so a recipient can only touch the ack fields,
-- nothing else on the record.
create or replace function acknowledge_counseling(counseling_id bigint)
returns void
language plpgsql security definer set search_path = public as $$
begin
  update counseling
  set acknowledged_by = auth.uid(), acknowledged_at = now()
  where id = counseling_id and recipient_profile_id = auth.uid();
end;
$$;

-- ─── ROTA / LEAVE ────────────────────────────────────────────────────────────

create table if not exists rotations (
  id bigint generated always as identity primary key,
  resident_id bigint not null references residents(id) on delete cascade,
  academic_year int not null,
  block_number int not null check (block_number between 1 and 13),
  block_label text,
  rotation_name text,
  leave_weeks int not null default 0,
  leave_position text not null default 'none' check (leave_position in ('none','start','end')),
  unique(resident_id, academic_year, block_number)
);

create table if not exists leave_records (
  id bigint generated always as identity primary key,
  resident_id bigint not null references residents(id) on delete cascade,
  type text not null check (type in ('annual','maternity','manual','unapproved_absence')),
  source text not null default 'manual' check (source in ('rota_import','manual')),
  academic_year int,
  block_number int,
  from_date date,
  to_date date,
  days int,
  comment text,
  approved boolean not null default true,
  created_by uuid references profiles(id),
  created_at timestamptz not null default now()
);

-- ─── PROMOTION LOG ───────────────────────────────────────────────────────────

create table if not exists promotion_log (
  id bigint generated always as identity primary key,
  academic_year int not null unique,
  executed_by uuid references profiles(id),
  executed_at timestamptz not null default now(),
  details jsonb
);

-- ─── ROW LEVEL SECURITY ──────────────────────────────────────────────────────

alter table consultants enable row level security;
alter table residents enable row level security;
alter table profiles enable row level security;
alter table account_privileges enable row level security;
alter table mentor_notes enable row level security;
alter table counseling enable row level security;
alter table rotations enable row level security;
alter table leave_records enable row level security;
alter table promotion_log enable row level security;

-- consultants: readable by anyone logged in (no secrets stored here), writes pd/chief only
create policy consultants_select on consultants for select to authenticated using (true);
create policy consultants_write on consultants for all to authenticated
  using (is_pd_or_chief()) with check (is_pd_or_chief());

-- profiles: readable by anyone logged in, writes pd/chief only
create policy profiles_select on profiles for select to authenticated using (true);
create policy profiles_write on profiles for all to authenticated
  using (is_pd_or_chief()) with check (is_pd_or_chief());

-- residents: pd/chief see all; consultant sees assigned; resident sees self
create policy residents_select on residents for select to authenticated using (
  is_pd_or_chief()
  or (app_role() = 'consultant' and mentor_id = app_consultant_id())
  or (app_role() = 'resident' and id = app_resident_id())
);
create policy residents_write on residents for all to authenticated
  using (is_pd_or_chief()) with check (is_pd_or_chief());

-- account_privileges: pd/chief manage all; a user can read their own grants
create policy privileges_select on account_privileges for select to authenticated using (
  is_pd_or_chief() or profile_id = auth.uid()
);
create policy privileges_write on account_privileges for all to authenticated
  using (is_pd_or_chief()) with check (is_pd_or_chief());

-- mentor_notes: pd/chief see all; consultant sees/writes their own notes; residents cannot see
create policy mentor_notes_select on mentor_notes for select to authenticated using (
  is_pd_or_chief() or (app_role() = 'consultant' and mentor_id = app_consultant_id())
);
create policy mentor_notes_write on mentor_notes for all to authenticated using (
  is_pd_or_chief() or (app_role() = 'consultant' and mentor_id = app_consultant_id())
) with check (
  is_pd_or_chief() or (app_role() = 'consultant' and mentor_id = app_consultant_id())
);

-- counseling: pd/chief see all; resident sees own; recipient sees theirs; mentor sees their residents'
create policy counseling_select on counseling for select to authenticated using (
  is_pd_or_chief()
  or resident_id = app_resident_id()
  or recipient_profile_id = auth.uid()
  or resident_id in (select id from residents where mentor_id = app_consultant_id())
);
create policy counseling_write on counseling for all to authenticated
  using (is_pd_or_chief()) with check (is_pd_or_chief());
-- Recipients acknowledge via the acknowledge_counseling() function only, not direct UPDATE.

-- rotations / leave_records: pd/chief see all; consultant sees assigned; resident sees self; writes pd/chief only
create policy rotations_select on rotations for select to authenticated using (
  is_pd_or_chief()
  or (app_role() = 'consultant' and resident_id in (select id from residents where mentor_id = app_consultant_id()))
  or resident_id = app_resident_id()
);
create policy rotations_write on rotations for all to authenticated
  using (is_pd_or_chief()) with check (is_pd_or_chief());

create policy leave_select on leave_records for select to authenticated using (
  is_pd_or_chief()
  or (app_role() = 'consultant' and resident_id in (select id from residents where mentor_id = app_consultant_id()))
  or resident_id = app_resident_id()
);
create policy leave_write on leave_records for all to authenticated
  using (is_pd_or_chief()) with check (is_pd_or_chief());

-- promotion_log: pd/chief only
create policy promotion_select on promotion_log for select to authenticated using (is_pd_or_chief());
create policy promotion_write on promotion_log for all to authenticated
  using (is_pd_or_chief()) with check (is_pd_or_chief());
