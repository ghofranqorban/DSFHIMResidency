-- Lists the PD edits in Control Centre > Lists: the rotation catalogue and the announcement categories.
-- Run in the Supabase SQL editor. Idempotent. Needs add_academic_years.sql first (for app_role()).
--
-- rotation_catalogue   one row per rotation the portal knows. The name is the key: the rota tables
--                      (rotations, rota_plan) and the portal's own rules store that text, so a name is
--                      never renamed, only its abbreviation, colours, SCFHS minimum weeks, credit,
--                      import spellings and order. A rotation is retired, never deleted, so old rota
--                      cells keep their colour and label.
-- announcement_categories  the categories offered when writing an announcement. The key is stored on
--                      each announcement, so a key is never renamed, only its label and order.
--
-- Both are read by every signed-in user and written by pd and deputy_pd only. The seed rows are the
-- portal's built-in lists, exactly as they were in the code, so nothing changes until you edit.

create table if not exists public.rotation_catalogue (
  name          text primary key,
  abbr          text not null,
  color_bg      text not null default '#FEFBF3',
  color_tx      text not null default '#475569',
  outline       text,
  mandatory     boolean not null default false,
  junior_weeks  smallint not null default 0 check (junior_weeks between 0 and 52),
  senior_weeks  smallint not null default 0 check (senior_weeks between 0 and 52),
  credits_to    text references public.rotation_catalogue(name),
  aliases       text[] not null default '{}',
  sort_order    smallint not null,
  active        boolean not null default true,
  updated_at    timestamptz not null default now(),
  updated_by    uuid
);

create table if not exists public.announcement_categories (
  key         text primary key,
  label       text not null,
  sort_order  smallint not null,
  active      boolean not null default true,
  updated_at  timestamptz not null default now(),
  updated_by  uuid
);

alter table public.rotation_catalogue       enable row level security;
alter table public.announcement_categories  enable row level security;

drop policy if exists rotation_catalogue_read on public.rotation_catalogue;
create policy rotation_catalogue_read on public.rotation_catalogue for select to authenticated using (true);
drop policy if exists rotation_catalogue_write on public.rotation_catalogue;
create policy rotation_catalogue_write on public.rotation_catalogue for all to authenticated
  using (coalesce(app_role() in ('pd','deputy_pd'), false))
  with check (coalesce(app_role() in ('pd','deputy_pd'), false));

drop policy if exists announcement_categories_read on public.announcement_categories;
create policy announcement_categories_read on public.announcement_categories for select to authenticated using (true);
drop policy if exists announcement_categories_write on public.announcement_categories;
create policy announcement_categories_write on public.announcement_categories for all to authenticated
  using (coalesce(app_role() in ('pd','deputy_pd'), false))
  with check (coalesce(app_role() in ('pd','deputy_pd'), false));

-- Seed: the built-in rotations. The order is the one the SCFHS tracker and the rota builder already
-- use (mandatory rotations first, then service, clinic, elective and leave, then Freeze); the rota
-- pickers now follow the same order. GIM/CTU comes first because Night Duty and Medical Consult credit
-- their weeks to it. Nothing is overwritten on a re-run.
insert into public.rotation_catalogue
  (name, abbr, color_bg, color_tx, outline, mandatory, junior_weeks, senior_weeks, credits_to, aliases, sort_order) values
  ('GIM/CTU', 'CTU', '#ede9fe', '#5b21b6', null, true, 24, 16, null, '{}', 1),
  ('Cardiology', 'Cardio', 'rgba(201,106,74,.12)', '#9d174d', null, true, 8, 8, null, '{}', 2),
  ('Pulmonology', 'Pulmo', '#e0f2fe', '#0c4a6e', null, true, 8, 4, null, '{}', 3),
  ('Nephrology', 'Nephro', 'rgba(127,184,156,.15)', '#26523A', null, true, 8, 4, null, '{}', 4),
  ('Gastroenterology', 'Gastro', 'rgba(164,122,40,.12)', '#6a4c10', null, true, 8, 8, null, '{}', 5),
  ('Endocrinology', 'Endo', '#f0fdf4', '#166534', null, true, 4, 8, null, '{}', 6),
  ('Hematology', 'Hema', '#ffe4e6', '#9f1239', null, true, 0, 8, null, '{}', 7),
  ('Rheumatology', 'Rheuma', '#f5f3ff', '#4c1d95', null, true, 4, 8, null, '{}', 8),
  ('Neurology', 'Neuro', '#fdf4ff', '#7e22ce', null, true, 4, 8, null, '{}', 9),
  ('Infectious Disease', 'ID', '#fff7ed', '#c2410c', null, true, 4, 8, null, '{}', 10),
  ('ICU', 'ICU', 'rgba(38,82,58,.12)', '#26523A', null, true, 8, 4, null, '{}', 11),
  ('Emergency Medicine', 'ER', '#fee2e2', '#7f1d1d', null, true, 8, 0, null, array['er','er main','em'], 12),
  ('Oncology', 'Onco', '#f0f9ff', '#0369a1', null, true, 0, 4, null, '{}', 13),
  ('Night Duty', 'Night', '#fef2f2', '#991b1b', null, false, 0, 0, 'GIM/CTU', '{}', 14),
  ('Medical Consult', 'M.Cons', '#eff6ff', '#26523A', null, false, 0, 0, 'GIM/CTU', array['m.con','m.cons','mcons','med consult'], 15),
  ('Outpatient Clinic', 'Clinic', '#F6EFE2', '#475569', null, false, 0, 0, null, '{}', 16),
  ('Elective', 'Elect', '#f0fdf4', '#166534', null, false, 0, 0, null, '{}', 17),
  ('Annual Leave', 'Leave', '#fefce8', '#854d0e', null, false, 0, 0, null, array['vacation','annual leave','leave','al'], 18),
  ('Maternity Leave', 'Matern', '#fdf4ff', '#701a75', null, false, 0, 0, null, array['matrnty','maternity','mat leave'], 19),
  ('Freeze', 'Freeze', '#f1f5f9', '#64748b', '1px dashed #cbd5e1', false, 0, 0, null, '{}', 20)
on conflict (name) do nothing;

insert into public.announcement_categories (key, label, sort_order) values
  ('task', 'Task', 1),
  ('research', 'Research', 2),
  ('qi', 'QI Project', 3),
  ('presentation', 'Presentation', 4),
  ('deadline', 'Deadline', 5),
  ('other', 'Other', 6),
  ('general', 'General', 7)
on conflict (key) do nothing;

-- Check: 20 rotations and 7 categories.
select name, abbr, mandatory, junior_weeks, senior_weeks, credits_to, aliases, sort_order, active from public.rotation_catalogue order by sort_order;
select key, label, sort_order, active from public.announcement_categories order by sort_order;
