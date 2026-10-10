-- Per-year rules for leave planning, quotas and preferences, editable in Control Centre > Leave and rules.
-- Run in the Supabase SQL editor. Idempotent. Needs add_academic_years.sql first.
--
-- A year's rules are kept as JSON on its academic_years row. An empty object means "use the portal's
-- built-in values", which are today's rules, so nothing changes until you edit. Keys the portal reads:
--   cap              people allowed per half-block of the leave plan (counted for annual leave only)
--   r1LockedBlocks   blocks an R1 cannot pick for leave, e.g. [1,2]
--   r3OnlyBlocks     blocks only an R3 can pick, e.g. [13]
--   uncappedBlocks   blocks with no cap on the number of people, e.g. [13]
--   annualQuota / eduQuota   days of annual and educational leave a year (28 and 7)
--   gimSlots         GIM preferences each level lists, e.g. {"R1":6,"R2":4,"R3":4,"R4":0}
--   r4EarlyMax       last block allowed for an R4's first elective and first clinic (7)
-- Written by pd and deputy_pd only, through the academic_years rule already in place.

alter table public.academic_years add column if not exists rules jsonb not null default '{}'::jsonb;

select ay, rules from public.academic_years order by ay;
