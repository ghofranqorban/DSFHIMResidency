-- ============================================================
-- Incoming R1 cohort for AY 2026-27 — 10 residents, all starting 4 Oct 2026.
--
-- RUN check_r1_2026_preflight.sql FIRST. If it reports any COLLISION,
-- change that username here before running this file.
--
-- Safe to re-run: ON CONFLICT (username) DO NOTHING, so a second run
-- inserts nothing and the verification below still reports the truth.
--
-- This creates the `residents` rows ONLY. It does NOT create logins —
-- `profiles` references auth.users, so an auth user must exist first.
-- Create logins afterwards through the portal's Admin Panel (which calls
-- the admin-create-login edge function); do not hand-insert into profiles.
--
-- `year_started` = 2026 because the portal numbers an academic year by the
-- cycle's start year, so 2026 is the 2026-27 cycle in which they are R1.
-- ============================================================

INSERT INTO residents (name, username, level, photo_initials, year_started, active)
VALUES
  ('Dr. Ghusun Muallim',   'ghusun',    'R1', 'GM', 2026, true),
  ('Dr. Abdulbari Bannan', 'abdulbari', 'R1', 'AB', 2026, true),
  ('Dr. Lina Abdulrahman', 'lina',      'R1', 'LA', 2026, true),
  ('Dr. Majid Hassan',     'majid',     'R1', 'MH', 2026, true),
  ('Dr. Shaden Benmohi',   'shaden',    'R1', 'SB', 2026, true),
  ('Dr. Lujain Baghlaf',   'lujain',    'R1', 'LB', 2026, true),
  ('Dr. Albaraa Sufyani',  'albaraa',   'R1', 'AS', 2026, true),
  ('Dr. Faris Almanea',    'faris',     'R1', 'FA', 2026, true),
  ('Dr. Wefag Sawadi',     'wefag',     'R1', 'WS', 2026, true),
  ('Dr. Fahad Alharbi',    'fahad',     'R1', 'FH', 2026, true)
ON CONFLICT (username) DO NOTHING;

-- ── VERIFY ──────────────────────────────────────────────────
-- Expect exactly 10 rows, every one 'INSERTED'.
-- 'MISSING' means the username collided with an existing resident and was
-- skipped — fix the username above and re-run.
WITH incoming(username) AS (
  VALUES ('ghusun'),('abdulbari'),('lina'),('majid'),('shaden'),
         ('lujain'),('albaraa'),('faris'),('wefag'),('fahad')
)
SELECT i.username,
       r.id,
       r.name,
       r.level,
       r.year_started,
       CASE
         WHEN r.id IS NULL                                   THEN 'MISSING - check for a collision'
         WHEN r.year_started = 2026 AND r.level = 'R1'        THEN 'INSERTED'
         ELSE 'WRONG - existing resident, not this cohort'
       END AS result
FROM incoming i
LEFT JOIN residents r ON lower(r.username) = i.username
ORDER BY i.username;
