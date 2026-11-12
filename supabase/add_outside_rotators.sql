-- Outside rotators: residents from other programmes who spend a few blocks with us.
-- They live in `residents` like everyone else, so the rota, the on-call schedule and an
-- optional login all work unchanged, but the portal keeps them OFF every programme list
-- (KPI, Best Resident, quizzes, attendance, mentorship, feedback, promotion review).
--
--   outside_rotator   true for a rotator from another programme
--   primary_specialty their home specialty, e.g. "Family Medicine"
--   rotator_ay        the academic year they rotate in (2026 = AY 2026-27). They show in
--                     that year's builder, rota and on-call only, and are never promoted.
--
-- Safe to run more than once. Run in the Supabase SQL editor.

alter table public.residents add column if not exists outside_rotator boolean not null default false;
alter table public.residents add column if not exists primary_specialty text;
alter table public.residents add column if not exists rotator_ay integer;

-- Check: every existing resident should read false / null / null.
select count(*) filter (where outside_rotator) as outside_rotators,
       count(*) as all_residents
from public.residents;

-- The 1 October promotion (pg_cron) still sees these rows. It would promote or archive an
-- outside rotator whose year has already ended, which does no harm because the portal only
-- shows them in their own rotator_ay. To keep promotion_log clean, add
--   and not outside_rotator
-- to the promotion function's WHERE clause. To see that function's code, run:
--   select proname, prosrc from pg_proc where prosrc ilike '%promotion_log%';
