-- Read-only. Three small results, no scrolling needed.
-- Checks that the historical rota is complete in the database.
--
-- Run this when the portal shows a resident with fewer years than expected. Note that a
-- resident can look short in the portal while being correct here: the portal reads
-- `rotations` over PostgREST, which caps a response at 1000 rows and does not report the
-- truncation, so loadRotaHistory() has to page. If these results are right and the portal
-- still disagrees, the fault is on the client side, not in the data.

-- 1. What is in the table now. One row. Expect 676 rows / 26 residents / 2021-2024.
select count(*) as hist_rows,
       count(distinct resident_id) as residents,
       string_agg(distinct academic_year::text, ', ' order by academic_year::text) as years
from rotations
where academic_year < 2025;

-- 2. Usernames the import expects that do NOT exist in residents.
--    Any row here means the import's guard divides by zero and the whole
--    transaction aborts, so nothing at all is written. Expect zero rows.
select u as missing_username
from unnest(array[
  'abdulmoty','alhussain','bajubair','bakur','bashanfar','bayazeed','deema',
  'farid','hamza','harbi','joharji','khalid','mansour','nawaf','nuha','omarb',
  'omarh','rafal','raghda','rasha','rowidh','samah','sarah','shifa','yara','zahra'
]) as u
where not exists (select 1 from residents where username = u);

-- 3. Per level: how many residents have any year before 2025. One row per level.
select res.level,
       count(*) as residents,
       count(*) filter (where h.n > 0) as with_history
from residents res
left join lateral (
  select count(*) as n from rotations r
  where r.resident_id = res.id and r.academic_year < 2025
) h on true
group by res.level
order by res.level;
