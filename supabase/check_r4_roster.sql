-- ============================================================
-- PRE-FLIGHT CHECK for the historical rota import (2022/2023/2024)
-- READ-ONLY. Changes nothing. Safe to run any number of times.
--
-- ONE statement on purpose: the Supabase SQL Editor only renders the
-- result of the last statement, so all 4 checks are UNIONed into a
-- single table. Select all, Run, and paste the whole grid back.
--
-- Every row in section 1 must read "OK - 1 match".
-- Section 4 must read "OK - clean insert".
-- ============================================================

WITH pat(portal_name, pattern) AS (
  VALUES
    ('Harbi',     '%Harbi%'),
    ('Joharji',   '%Joharji%'),
    ('Bashanfar', '%Bashanfar%'),
    ('Omar B',    '%Omar B%'),
    ('Zahra',     '%Zahra%'),
    ('Yara',      '%Yara%'),
    ('Rafal',     '%Rafal%')
),
match_check AS (
  SELECT
    p.portal_name,
    p.pattern,
    count(r.id) AS n,
    coalesce(
      string_agg(r.name || ' (id ' || r.id || ')', ' | ' ORDER BY r.id),
      '(nothing)'
    ) AS hits
  FROM pat p
  LEFT JOIN residents r
    ON r.name ILIKE p.pattern
   AND r.level = 'R4'
  GROUP BY p.portal_name, p.pattern
),
prior AS (
  SELECT count(*) AS n
  FROM rotations
  WHERE academic_year IN (2022, 2023, 2024)
),
report AS (

  -- ── 1. Do the 7 import patterns each resolve to exactly one R4? ──
  SELECT
    1                              AS sort_a,
    portal_name                    AS sort_b,
    '1. PATTERN CHECK'             AS section,
    portal_name                    AS item,
    pattern || '  ->  ' || hits    AS detail,
    CASE
      WHEN n = 1 THEN 'OK - 1 match'
      WHEN n = 0 THEN 'FAIL - no match, pattern needs widening'
      ELSE            'FAIL - ambiguous, ' || n || ' residents match'
    END                            AS verdict
  FROM match_check

  UNION ALL

  -- ── 2. Full R4 roster. Expect exactly 7. ────────────────────────
  SELECT
    2,
    name,
    '2. R4 ROSTER',
    name,
    'id ' || id
      || ' | username ' || coalesce(username, '-')
      || ' | active '   || active
      || ' | started '  || coalesce(year_started::text, '-'),
    CASE WHEN archived_at IS NULL THEN 'active' ELSE 'ARCHIVED' END
  FROM residents
  WHERE level = 'R4'

  UNION ALL

  -- ── 3. Every Omar, any level. Guards the Omar B / Omar H mix-up. ─
  SELECT
    3,
    level || name,
    '3. ALL OMARS',
    name,
    'id ' || id || ' | level ' || level || ' | active ' || active,
    CASE
      WHEN name ILIKE '%Omar B%' AND level = 'R4' THEN 'TARGET - import writes here'
      WHEN name ILIKE '%Omar B%'                  THEN 'WARNING - matches pattern, wrong level'
      ELSE                                             'not matched - correct'
    END
  FROM residents
  WHERE name ILIKE '%Omar%'

  UNION ALL

  -- ── 4. Are the target years already populated? Expect zero. ─────
  SELECT
    4,
    '',
    '4. EXISTING ROWS 2022-24',
    'rotations already in AY 2022/2023/2024',
    prior.n || ' rows',
    CASE WHEN prior.n = 0
         THEN 'OK - clean insert'
         ELSE 'STOP - years are not empty, tell Claude before importing'
    END
  FROM prior
)
SELECT section, item, detail, verdict
FROM report
ORDER BY sort_a, sort_b;
