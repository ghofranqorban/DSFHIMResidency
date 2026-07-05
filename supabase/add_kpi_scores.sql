-- KPI manual scores table
-- Stores committee score, research/QI participation, and bonus achievements
-- per resident per academic year. Run once in Supabase SQL Editor.

create table if not exists kpi_scores (
  id bigint generated always as identity primary key,
  resident_id bigint not null references residents(id) on delete cascade,
  academic_year int not null,
  committee_score int not null default 0 check (committee_score between 0 and 10),
  research_participated boolean not null default false,
  qi_participated boolean not null default false,
  bonus_published boolean not null default false,   -- research paper published
  bonus_oral boolean not null default false,         -- oral presentation at conference
  bonus_poster boolean not null default false,       -- poster presentation at conference
  updated_by uuid references profiles(id),
  updated_at timestamptz not null default now(),
  unique(resident_id, academic_year)
);

alter table kpi_scores enable row level security;

-- pd/chief see all; consultant sees their assigned residents; resident sees self
create policy kpi_select on kpi_scores for select to authenticated using (
  is_pd_or_chief()
  or (app_role()='consultant' and resident_id in (select id from residents where mentor_id=app_consultant_id()))
  or (app_role()='resident' and resident_id=app_resident_id())
);

-- pd/chief or assigned mentor can write
create policy kpi_write on kpi_scores for all to authenticated
  using (
    is_pd_or_chief()
    or (app_role()='consultant' and resident_id in (select id from residents where mentor_id=app_consultant_id()))
  )
  with check (
    is_pd_or_chief()
    or (app_role()='consultant' and resident_id in (select id from residents where mentor_id=app_consultant_id()))
  );
