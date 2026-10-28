-- DSFH Residency Portal — Resident feedback (28 Oct 2026)
-- Two features, both read by the Program Director ALONE (role 'pd'; deputy, chief and consultants have
-- no access to these rows). (1) General feedback a resident sends at any time, under their name, which the
-- PD reads in an inbox. (2) Programme review rounds: the PD opens a round for an academic year and a block
-- range with a due date; each resident answers once, by name. Residents may insert and read their own rows
-- only, and only while the round is open. Chief residents count as residents here.
-- Run once in the Supabase SQL Editor. The last statement opens the first round (Blocks 11–13 of AY 2025-26).

create table if not exists feedback_rounds (
  id bigint generated always as identity primary key,
  academic_year int not null,
  block_from int not null check (block_from between 1 and 13),
  block_to int not null check (block_to between 1 and 13 and block_to >= block_from),
  label text,
  deadline date,
  is_open boolean not null default false,
  opened_at timestamptz,
  updated_at timestamptz not null default now(),
  updated_by uuid references profiles(id)
);

create table if not exists feedback_round_responses (
  id bigint generated always as identity primary key,
  round_id bigint not null references feedback_rounds(id) on delete cascade,
  resident_id bigint not null references residents(id) on delete cascade,
  level text,                                  -- R1..R4 at the time of answering
  answers jsonb not null default '{}'::jsonb,  -- {items:{key:1..5}, texts:{key:text}, rotations:[{name,blocks,rating,comment}]}
  submitted_at timestamptz not null default now(),
  unique (round_id, resident_id)
);

create table if not exists feedback_general (
  id bigint generated always as identity primary key,
  resident_id bigint not null references residents(id) on delete cascade,
  level text,
  category text not null,
  subject text not null,
  message text not null,
  status text not null default 'new' check (status in ('new','read','addressed')),
  pd_note text,
  reviewed_at timestamptz,
  reviewed_by uuid references profiles(id),
  created_at timestamptz not null default now()
);

create index if not exists feedback_round_responses_round_idx on feedback_round_responses(round_id);
create index if not exists feedback_general_status_idx on feedback_general(status);

alter table feedback_rounds enable row level security;
alter table feedback_round_responses enable row level security;
alter table feedback_general enable row level security;

-- Rounds: anyone signed in may read them (a resident has to know a round is open); only the PD writes.
drop policy if exists feedback_rounds_select on feedback_rounds;
create policy feedback_rounds_select on feedback_rounds for select to authenticated using (true);
drop policy if exists feedback_rounds_write on feedback_rounds;
create policy feedback_rounds_write on feedback_rounds for all to authenticated
  using (app_role() = 'pd') with check (app_role() = 'pd');

-- Responses: a resident inserts and reads their own, while the round is open; the PD reads all.
-- No update and no delete for anyone through the app.
drop policy if exists feedback_round_responses_select on feedback_round_responses;
create policy feedback_round_responses_select on feedback_round_responses for select to authenticated using (
  app_role() = 'pd'
  or (app_role() in ('resident','chief') and resident_id = app_resident_id())
);
drop policy if exists feedback_round_responses_insert on feedback_round_responses;
create policy feedback_round_responses_insert on feedback_round_responses for insert to authenticated with check (
  app_role() in ('resident','chief') and resident_id = app_resident_id()
  and exists (select 1 from feedback_rounds r where r.id = feedback_round_responses.round_id and r.is_open)
);

-- General feedback: a resident inserts under their own id and reads their own; the PD reads all and
-- updates status and note.
drop policy if exists feedback_general_select on feedback_general;
create policy feedback_general_select on feedback_general for select to authenticated using (
  app_role() = 'pd'
  or (app_role() in ('resident','chief') and resident_id = app_resident_id())
);
drop policy if exists feedback_general_insert on feedback_general;
create policy feedback_general_insert on feedback_general for insert to authenticated with check (
  app_role() in ('resident','chief') and resident_id = app_resident_id()
);
drop policy if exists feedback_general_update on feedback_general;
create policy feedback_general_update on feedback_general for update to authenticated
  using (app_role() = 'pd') with check (app_role() = 'pd');

grant select, insert, update, delete on feedback_rounds to authenticated;
grant select, insert on feedback_round_responses to authenticated;
grant select, insert, update on feedback_general to authenticated;

-- First round: the last three blocks of AY 2025-26, due 15 November 2026. Change the date if you like.
insert into feedback_rounds (academic_year, block_from, block_to, label, deadline, is_open, opened_at)
select 2025, 11, 13, 'Blocks 11–13 · AY 2025-26', date '2026-11-15', true, now()
where not exists (select 1 from feedback_rounds where academic_year = 2025 and block_from = 11 and block_to = 13);

-- Check afterwards (expect 2 + 2 + 3 policies, and one open round):
-- select polrelid::regclass, polname, polcmd from pg_policy where polrelid::regclass::text like 'feedback_%' order by 1,2;
-- select * from feedback_rounds;
