-- DSFH Residency Portal — Migration 003
-- Adds real database tables for the Morning Meeting schedule and the
-- Tuesday/Wednesday Teaching schedule (previously hardcoded in the page's
-- JavaScript and lost on every reload).
-- Run this once in the Supabase SQL editor (same place as schema.sql /
-- migration_001 / migration_002). Safe to re-run.

-- ─── PRIVILEGES: let PD grant specific people "schedule editor" access ──────
-- (separate from the existing 'edit_mm_attendance'/'edit_teach_attendance'
-- keys, which control marking attendance, not writing the schedule itself)
alter table account_privileges drop constraint if exists account_privileges_privilege_key_check;
alter table account_privileges add constraint account_privileges_privilege_key_check check (privilege_key in (
  'edit_quiz_marks','edit_mm_attendance','edit_teach_attendance','edit_kpi_notes',
  'edit_mm_schedule','edit_teach_schedule'
));

-- Helper used by RLS below: does the logged-in user hold a given privilege key?
create or replace function has_priv(key text) returns boolean
language sql stable security definer set search_path = public as $$
  select exists(
    select 1 from account_privileges where profile_id = auth.uid() and privilege_key = key
  );
$$;

-- ─── MORNING MEETING SCHEDULE ───────────────────────────────────────────────
create table if not exists mm_sessions (
  id bigint generated always as identity primary key,
  academic_year int not null,
  block_number int not null check (block_number between 1 and 13),
  week_number int not null,          -- 0-based global week index since block 1 week 1 (matches ROTA_PERIODS)
  session_date date not null,
  day_label text,                    -- e.g. "Sunday" (kept as free text to match the distributed sheet verbatim)
  topic text,
  presenter_resident_id bigint references residents(id) on delete set null,
  presenter_label text,              -- free-text fallback (e.g. "Dr. Nahed", "Cardiology Fellow", "TBH")
  moderator_resident_id bigint references residents(id) on delete set null,
  moderator_label text,
  consultant_label text,             -- e.g. "Multiple Consultants" — free text, not tied to the consultants table
  row_highlight text,                -- e.g. 'special' for Departmental Meeting/M&M/ACS rows, 'magenta' for the Dr. Nahed row
  created_by uuid references profiles(id),
  created_at timestamptz not null default now()
);

-- ─── TEACHING SCHEDULE (Tue/Wed, 3-5pm fixed, consultant/fellow only) ──────
create table if not exists teaching_sessions (
  id bigint generated always as identity primary key,
  academic_year int not null,
  block_number int not null check (block_number between 1 and 13),
  week_number int not null,
  session_date date not null,
  day_label text,
  topic text,
  specialty_label text,              -- e.g. "Endocrine" — the department/subspecialty column from the committee's sheet
  presenter_label text not null,     -- free text: consultant/fellow name (not tied to residents/consultants tables)
  role_label text check (role_label in ('Consultant','Fellow')),
  created_by uuid references profiles(id),
  created_at timestamptz not null default now()
);

-- ─── ATTENDANCE (previously kept only in the browser's memory — lost on every
-- reload; moving it to the database too so it actually persists) ───────────
create table if not exists mm_attendance (
  id bigint generated always as identity primary key,
  session_id bigint not null references mm_sessions(id) on delete cascade,
  resident_id bigint not null references residents(id) on delete cascade,
  status text not null check (status in ('P','L','A')),
  marked_by uuid references profiles(id),
  marked_at timestamptz not null default now(),
  unique(session_id, resident_id)
);

create table if not exists teaching_attendance (
  id bigint generated always as identity primary key,
  session_id bigint not null references teaching_sessions(id) on delete cascade,
  resident_id bigint not null references residents(id) on delete cascade,
  status text not null check (status in ('P','L','A')),
  marked_by uuid references profiles(id),
  marked_at timestamptz not null default now(),
  unique(session_id, resident_id)
);

alter table mm_sessions enable row level security;
alter table teaching_sessions enable row level security;
alter table mm_attendance enable row level security;
alter table teaching_attendance enable row level security;

-- Everyone logged in can read both schedules and attendance.
create policy mm_sessions_select on mm_sessions for select to authenticated using (true);
create policy teaching_sessions_select on teaching_sessions for select to authenticated using (true);
create policy mm_attendance_select on mm_attendance for select to authenticated using (true);
create policy teaching_attendance_select on teaching_attendance for select to authenticated using (true);

-- Schedule writes: PD/chief always; plus anyone specifically granted the matching privilege.
create policy mm_sessions_write on mm_sessions for all to authenticated
  using (is_pd_or_chief() or has_priv('edit_mm_schedule'))
  with check (is_pd_or_chief() or has_priv('edit_mm_schedule'));

create policy teaching_sessions_write on teaching_sessions for all to authenticated
  using (is_pd_or_chief() or has_priv('edit_teach_schedule'))
  with check (is_pd_or_chief() or has_priv('edit_teach_schedule'));

-- Attendance writes: PD/chief always; plus anyone granted the existing attendance-logging privilege.
create policy mm_attendance_write on mm_attendance for all to authenticated
  using (is_pd_or_chief() or has_priv('edit_mm_attendance'))
  with check (is_pd_or_chief() or has_priv('edit_mm_attendance'));

create policy teaching_attendance_write on teaching_attendance for all to authenticated
  using (is_pd_or_chief() or has_priv('edit_teach_attendance'))
  with check (is_pd_or_chief() or has_priv('edit_teach_attendance'));
