-- DSFH Residency Portal — Resident Milestone self-assessment (second tab of the Mentorship ILP module)
-- Before each six-monthly Clinical Competency Committee review a resident rates their own progress on the
-- 19 ACGME-I Internal Medicine Milestone sub-competencies (level 1-5) and writes two short texts.
-- One row per resident per academic year per period (1 = Oct–Mar, 2 = Apr–Sep). The resident reads and
-- writes only their own rows and only while the period is not locked; a consultant reads the rows of the
-- residents they mentor; pd / deputy_pd / chief read every row (is_pd_or_chief()).
-- self_assessment_periods holds the per-year, per-period configuration (due date, lock): readable by every
-- signed-in user, written by pd / deputy_pd only.
-- Run once in the Supabase SQL Editor.

create table if not exists self_assessment_periods (
  id bigint generated always as identity primary key,
  academic_year int not null,
  period int not null check (period in (1,2)),
  label text,
  due_on date,
  locked boolean not null default false,
  locked_at timestamptz,
  locked_by uuid references profiles(id),
  updated_by uuid references profiles(id),
  updated_at timestamptz not null default now(),
  unique (academic_year, period)
);

create table if not exists self_assessments (
  id bigint generated always as identity primary key,
  resident_id bigint not null references residents(id) on delete cascade,
  academic_year int not null,
  period int not null check (period in (1,2)),
  levels jsonb not null default '{}'::jsonb,      -- {PC1..ICS3} -> 1..5
  doing_well text,
  work_on text,
  status text not null default 'draft' check (status in ('draft','submitted')),
  submitted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (resident_id, academic_year, period)
);

create index if not exists self_assessments_resident_idx on self_assessments(resident_id, academic_year);

alter table self_assessment_periods enable row level security;
alter table self_assessments enable row level security;

-- Periods: everyone signed in reads; pd / deputy_pd write.
drop policy if exists self_assessment_periods_select on self_assessment_periods;
create policy self_assessment_periods_select on self_assessment_periods for select to authenticated using (true);

drop policy if exists self_assessment_periods_write on self_assessment_periods;
create policy self_assessment_periods_write on self_assessment_periods for all to authenticated
  using (app_role() in ('pd','deputy_pd'))
  with check (app_role() in ('pd','deputy_pd'));

-- Self-assessments: own rows, mentee rows, or pd/chief.
drop policy if exists self_assessments_select on self_assessments;
create policy self_assessments_select on self_assessments for select to authenticated using (
  is_pd_or_chief()
  or (app_role() = 'resident' and resident_id = app_resident_id())
  or (app_role() = 'consultant' and exists (
        select 1 from residents r where r.id = self_assessments.resident_id and r.mentor_id = app_consultant_id()))
);

-- A resident writes only their own row, only after the half-year has ended (period 1 = Oct–Mar, so from
-- 1 April; period 2 = Apr–Sep, so from 1 October of the next academic year), and only while the period is
-- not locked by the PD.
drop policy if exists self_assessments_write on self_assessments;
create policy self_assessments_write on self_assessments for all to authenticated using (
  app_role() = 'resident' and resident_id = app_resident_id()
  and current_date >= case period when 1 then make_date(academic_year + 1, 4, 1) else make_date(academic_year + 1, 10, 1) end
  and not exists (select 1 from self_assessment_periods p
                  where p.academic_year = self_assessments.academic_year and p.period = self_assessments.period and p.locked)
) with check (
  app_role() = 'resident' and resident_id = app_resident_id()
  and current_date >= case period when 1 then make_date(academic_year + 1, 4, 1) else make_date(academic_year + 1, 10, 1) end
  and not exists (select 1 from self_assessment_periods p
                  where p.academic_year = self_assessments.academic_year and p.period = self_assessments.period and p.locked)
);

grant select, insert, update, delete on self_assessment_periods to authenticated;
grant select, insert, update, delete on self_assessments to authenticated;

-- Check afterwards (expected: two policies on each table):
select polrelid::regclass, polname, polcmd from pg_policy
 where polrelid in ('self_assessments'::regclass, 'self_assessment_periods'::regclass);
