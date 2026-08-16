-- Split the pre-existing "A / B" rotation names into proper two-segment rows.
--
-- Before segments existed, commitRotaImport() stored a dual-rotation block by
-- concatenating both names into one cell. Those rows do not match any entry in
-- ALL_ROTATIONS, so they render unstyled and count as zero weeks of either
-- rotation. Known cases are in AY 2025, but this finds them by shape rather than
-- by name so nothing is missed.
--
-- Run AFTER migrate_rotations_segments.sql. Safe to run more than once: once a
-- row is split its name no longer contains a slash, so it stops matching.

begin;

-- 1. Show what is about to change. Read this before trusting the rest.
select r.id, res.username, r.academic_year, r.block_number, r.rotation_name,
       split_part(r.rotation_name, ' / ', 1) as will_become_segment_1,
       split_part(r.rotation_name, ' / ', 2) as will_become_segment_2
from rotations r
join residents res on res.id = r.resident_id
where r.rotation_name like '% / %'
order by res.username, r.academic_year, r.block_number;

-- 2. Insert the second half as segment 2.
insert into rotations
  (resident_id, academic_year, block_number, segment, rotation_name, weeks, leave_weeks, leave_position)
select r.resident_id, r.academic_year, r.block_number, 2,
       btrim(split_part(r.rotation_name, ' / ', 2)), 2, 0, 'none'
from rotations r
where r.rotation_name like '% / %'
  and r.segment = 1
  and btrim(split_part(r.rotation_name, ' / ', 2)) <> ''
on conflict (resident_id, academic_year, block_number, segment) do nothing;

-- 3. Reduce the original row to just the first half.
update rotations
set rotation_name = btrim(split_part(rotation_name, ' / ', 1)),
    weeks = 2
where rotation_name like '% / %'
  and segment = 1;

commit;

-- Verify: both queries should return zero rows.
--   select * from rotations where rotation_name like '% / %';
--   select rotation_name from rotations
--   where rotation_name not in (
--     'GIM/CTU','Night Duty','ICU','Cardiology','Pulmonology','Nephrology',
--     'Gastroenterology','Endocrinology','Hematology','Rheumatology','Neurology',
--     'Infectious Disease','Emergency Medicine','Oncology','Outpatient Clinic',
--     'Elective','Annual Leave','Maternity Leave','Medical Consult','Freeze')
--   and coalesce(rotation_name,'') <> '';
