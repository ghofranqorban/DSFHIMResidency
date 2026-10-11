-- Scoring settings, editable in Control Centre > Scoring. Run in the Supabase SQL editor. Idempotent.
-- Needs add_academic_years.sql first (it creates portal_settings and its two rules: every signed-in
-- user reads, pd and deputy_pd write).
--
-- One row, key 'scoring', holds every number the scoring screens read:
--   kpiW       yearly KPI score weights, points of 100 (oral and poster share one weight)
--   standards  quiz pass mark and attendance bar behind the met / not met verdicts
--   bands      where a score turns good / fair / low (green, amber, red)
--   tiers      the four tier names used by the Performance Report headline
--   atRisk     the Residents table flags a resident whose KPI or attendance is under this
--   br         Best Resident: KPI share + votes share = 100; quiz + mm + teach = KPI share
-- The row below is the portal's built-in scoring, so nothing changes until you edit it. The portal
-- falls back to the same numbers if the row is missing or any group does not add up.

insert into public.portal_settings (key, value) values ('scoring', '{
  "kpiW": {"quiz": 15, "mm": 15, "teach": 15, "pres": 5, "comm": 10, "qi": 10, "pub": 10, "oral": 10, "awards": 5, "volunteering": 5},
  "standards": {"quiz": 60, "attendance": 75},
  "bands": {"good": 80, "fair": 60, "low": 30},
  "tiers": {"good": "Outstanding", "fair": "Strong Progress", "low": "Developing", "below": "Needs Improvement"},
  "atRisk": 60,
  "br": {"kpiPct": 60, "votePct": 40, "quiz": 30, "mm": 15, "teach": 15}
}'::jsonb) on conflict (key) do nothing;

select key, value, updated_at from public.portal_settings where key = 'scoring';
