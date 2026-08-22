-- ============================================================
-- PRE-FLIGHT for the incoming R1 cohort, AY 2026-27 (10 residents).
-- READ-ONLY. Changes nothing. Run this BEFORE add_r1_cohort_2026.sql.
--
-- ONE statement on purpose: the Supabase SQL Editor only renders the
-- result of the LAST statement, so every check is UNIONed into one grid.
-- Select all, Run, paste the whole grid back.
--
-- WHAT TO LOOK FOR
--   Section 1: every row must read 'OK - free'. Any 'COLLISION' means that
--              username is already taken and must be changed before insert.
--   Section 2: should read 'OK - none yet'. Anything else means some or all
--              of this cohort was already added (the insert is then a no-op).
--   Section 3: informational - the usernames already in use, so a new one
--              can be picked by hand if section 1 reports a collision.
-- ============================================================

WITH incoming(username, full_name) AS (
  VALUES
    ('ghusun',    'Dr. Ghusun Muallim'),
    ('abdulbari', 'Dr. Abdulbari Bannan'),
    ('lina',      'Dr. Lina Abdulrahman'),
    ('majid',     'Dr. Majid Hassan'),
    ('shaden',    'Dr. Shaden Benmohi'),
    ('lujain',    'Dr. Lujain Baghlaf'),
    ('albaraa',   'Dr. Albaraa Sufyani'),
    ('faris',     'Dr. Faris Almanea'),
    ('wefag',     'Dr. Wefag Sawadi'),
    ('fahad',     'Dr. Fahad Alharbi')
)

-- 1 ── username availability (checks residents AND profiles: both are UNIQUE)
SELECT '1. username' AS section,
       i.username    AS detail,
       i.full_name   AS extra,
       CASE
         WHEN EXISTS (SELECT 1 FROM residents r WHERE lower(r.username) = i.username)
           THEN 'COLLISION - taken in residents'
         WHEN EXISTS (SELECT 1 FROM profiles p WHERE lower(p.username) = i.username)
           THEN 'COLLISION - taken in profiles'
         ELSE 'OK - free'
       END AS result
FROM incoming i

UNION ALL

-- 2 ── has this cohort already been inserted?
SELECT '2. already added',
       count(*)::text,
       '',
       CASE WHEN count(*) = 0 THEN 'OK - none yet'
            ELSE 'ALREADY PRESENT - insert will skip these' END
FROM residents
WHERE year_started = 2026 AND level = 'R1'

UNION ALL

-- 3 ── a similar-name sweep, in case someone exists under a different username
SELECT '3. name match',
       r.username,
       r.name || ' (' || r.level || ', started ' || r.year_started || ')',
       'REVIEW - resembles an incoming name'
FROM residents r
WHERE r.name ILIKE ANY (ARRAY[
        '%Ghusun%','%Muallim%','%Abdulbari%','%Bannan%','%Lina%','%Abdulrahman%',
        '%Majid%','%Hassan%','%Shaden%','%Benmohi%','%Lujain%','%Baghlaf%',
        '%Albaraa%','%Sufyani%','%Faris%','%Almanea%','%Wefag%','%Sawadi%',
        '%Fahad%','%Alharbi%'])

UNION ALL

-- 4 ── current roster size, for a sanity check after the insert
SELECT '4. roster now',
       count(*) FILTER (WHERE active)::text || ' active',
       count(*)::text || ' total',
       'INFO - expect +10 active after insert'
FROM residents

ORDER BY section, detail;
