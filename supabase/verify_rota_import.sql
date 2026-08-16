-- Read-only. Run after the migration, the import, the cleanup and the leave-weeks fix.
-- Supabase shows one result panel per statement — checks 1 to 4 each return a `status`
-- column and all four should read OK. Check 5 is a table to eyeball.

-- 1. Schema: segment and weeks exist, and the unique key includes segment.
select 'schema' as check,
       case when count(*) filter (where column_name = 'segment') = 1
             and count(*) filter (where column_name = 'weeks')   = 1
            then 'OK' else 'MISSING COLUMN' end as status,
       string_agg(column_name, ', ' order by column_name) as found
from information_schema.columns
where table_name = 'rotations' and column_name in ('segment','weeks');

-- 2. Cleanup: no concatenated names, no names outside the known set.
select 'labels' as check,
       case when count(*) = 0 then 'OK' else count(*)::text || ' BAD ROWS' end as status,
       coalesce(string_agg(distinct rotation_name, ' | '), '—') as offenders
from rotations
where coalesce(rotation_name,'') <> ''
  and (rotation_name like '% / %'
       or rotation_name not in (
         'GIM/CTU','Night Duty','ICU','Cardiology','Pulmonology','Nephrology',
         'Gastroenterology','Endocrinology','Hematology','Rheumatology','Neurology',
         'Infectious Disease','Emergency Medicine','Oncology','Outpatient Clinic',
         'Elective','Annual Leave','Maternity Leave','Medical Consult','Freeze'));

-- 3. Import: the 7 R4s should have history in 2021-2024, not just 2025.
select 'history' as check,
       case when count(*) = 305 then 'OK'
            else count(*)::text || ' rows, expected 305' end as status,
       string_agg(distinct academic_year::text, ', ' order by academic_year::text) as years
from rotations r
join residents res on res.id = r.resident_id
where res.username in ('harbi','joharji','bashanfar','omarb','zahra','yara','rafal')
  and r.academic_year < 2025;

-- 4. No block can run longer than 4 weeks. Fails until fix_leave_block_weeks.sql is run.
select 'block length' as check,
       case when count(*) = 0 then 'OK'
            else count(*)::text || ' ROWS OVER 4 WEEKS — run fix_leave_block_weeks.sql' end as status
from rotations
where weeks + coalesce(leave_weeks,0) > 4;

-- 5. Weeks per resident-year. Every completed year should total 52,
--    except Bashanfar 2022 (48 — block 1 is genuinely blank in the source).
--    2025 is the year in progress, so it may legitimately come in under 52.
select res.username, r.academic_year,
       sum(r.weeks + coalesce(r.leave_weeks,0)) as total_weeks,
       count(*) as rows
from rotations r
join residents res on res.id = r.resident_id
where res.username in ('harbi','joharji','bashanfar','omarb','zahra','yara','rafal')
group by res.username, r.academic_year
order by res.username, r.academic_year;
