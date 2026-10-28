-- DSFH Residency Portal — Mentorship Individualized Learning Plan (CanMEDS)
-- One row per resident per academic year per quarter. The mentor rates the seven CanMEDS roles
-- (1-5) with a comment each, then strengths, areas to develop, an action plan and an overall rating.
-- status: 'draft' is the mentor's working copy; 'submitted' is locked for the mentor and visible
-- to the resident. pd / deputy_pd / chief read and write every row (is_pd_or_chief()); a consultant
-- only rows where they are the mentor; a resident reads their own submitted rows.
-- Run once in the Supabase SQL Editor.

create table if not exists mentorship_evaluations (
  id bigint generated always as identity primary key,
  resident_id bigint not null references residents(id) on delete cascade,
  mentor_id bigint references consultants(id) on delete set null,
  academic_year int not null,
  quarter int not null check (quarter between 1 and 4),
  ratings jsonb not null default '{}'::jsonb,     -- {expert,comm,collab,manager,advocate,scholar,prof} -> 1..5
  comments jsonb not null default '{}'::jsonb,    -- same keys -> text
  strengths text,
  improvements text,
  action_plan text,
  overall int check (overall between 1 and 5),
  status text not null default 'draft' check (status in ('draft','submitted')),
  submitted_at timestamptz,
  created_by uuid references profiles(id),
  updated_by uuid references profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (resident_id, academic_year, quarter)
);

create index if not exists mentorship_evaluations_resident_idx on mentorship_evaluations(resident_id, academic_year);

alter table mentorship_evaluations enable row level security;

drop policy if exists mentorship_evaluations_select on mentorship_evaluations;
create policy mentorship_evaluations_select on mentorship_evaluations for select to authenticated using (
  is_pd_or_chief()
  or (app_role() = 'consultant' and mentor_id = app_consultant_id())
  or (app_role() = 'resident' and resident_id = app_resident_id() and status = 'submitted')
);

drop policy if exists mentorship_evaluations_write on mentorship_evaluations;
create policy mentorship_evaluations_write on mentorship_evaluations for all to authenticated using (
  is_pd_or_chief()
  or (app_role() = 'consultant' and mentor_id = app_consultant_id())
) with check (
  is_pd_or_chief()
  or (app_role() = 'consultant' and mentor_id = app_consultant_id())
);

-- Check afterwards:
-- select polname, cmd from pg_policy where polrelid = 'mentorship_evaluations'::regclass;
