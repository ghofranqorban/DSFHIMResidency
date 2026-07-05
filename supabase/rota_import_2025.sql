-- ============================================================
-- DSFH Rota Import — Academic Year 2025-2026
-- 40 residents × 13 blocks = up to 520 rows
-- Safe to re-run: uses ON CONFLICT ... DO UPDATE
-- ============================================================

BEGIN;

-- R4 Harbi
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Harbi%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Harbi';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Hematology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'ICU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Outpatient Clinic',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Rheumatology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'ICU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Endocrinology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Outpatient Clinic',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Elective',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Elective',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Annual Leave',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R4 Joharji
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Joharji%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Joharji';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Hematology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Pulmonology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Outpatient Clinic',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Endocrinology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Rheumatology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Outpatient Clinic',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Elective',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Elective',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Annual Leave',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R4 Bashanfar
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Bashanfar%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Bashanfar';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Oncology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Endocrinology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Elective',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Nephrology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Elective',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Pulmonology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Rheumatology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Outpatient Clinic',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Outpatient Clinic',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Rheumatology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R4 Omar B
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Omar%' OR name ILIKE '%B%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Omar B';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Outpatient Clinic',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Endocrinology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Rheumatology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Pulmonology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Outpatient Clinic',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Elective',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Elective',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Annual Leave',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R4 Zahra
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Zahra%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Zahra';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'ICU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Endocrinology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Pulmonology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Outpatient Clinic',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Rheumatology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Outpatient Clinic',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Elective',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Elective',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Annual Leave',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R4 Yara
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Yara%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Yara';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Endocrinology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Outpatient Clinic',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Pulmonology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Elective',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Elective',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Endocrinology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Rheumatology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Outpatient Clinic',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Rheumatology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R4 Rafal
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Rafal%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Rafal';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Pulmonology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Rheumatology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Pulmonology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Outpatient Clinic',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Outpatient Clinic',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Elective',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Elective',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Annual Leave',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R3 Abdulmoty
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Abdulmoty%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Abdulmoty';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'ICU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Emergency Medicine',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Oncology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Neurology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Hematology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Pulmonology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R3 Alhussain
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Alhussain%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Alhussain';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Endocrinology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Rheumatology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Oncology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'ICU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Endocrinology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Hematology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R3 Omar H
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Omar%' OR name ILIKE '%H%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Omar H';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Emergency Medicine',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Pulmonology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Hematology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'ICU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Gastroenterology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Oncology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R3 Rowidh
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Rowidh%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Rowidh';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Rheumatology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Emergency Medicine',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Oncology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'ICU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Nephrology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Pulmonology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R3 Nawaf
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Nawaf%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Nawaf';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Oncology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'ICU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Pulmonology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Emergency Medicine',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Nephrology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Hematology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R3 Mansour
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Mansour%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Mansour';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Hematology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Rheumatology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Neurology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'ICU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Pulmonology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Gastroenterology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R3 Raghda
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Raghda%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Raghda';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'ICU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Infectious Disease',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Emergency Medicine',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Hematology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Endocrinology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R3 Sarah
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Sarah%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Sarah';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Pulmonology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Emergency Medicine',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Hematology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Oncology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'ICU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Endocrinology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R3 Rasha
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Rasha%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Rasha';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Neurology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Oncology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Hematology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'ICU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Emergency Medicine',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Endocrinology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Gastroenterology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R2 Bayazeed
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Bayazeed%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Bayazeed';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Medical Consult',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Endocrinology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'ICU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Gastroenterology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Nephrology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R2 Nuha
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Nuha%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Nuha';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Medical Consult',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Pulmonology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'ICU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Gastroenterology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Nephrology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R2 Hamza
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Hamza%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Hamza';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Medical Consult',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Endocrinology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'ICU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Gastroenterology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R2 Bajubair
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Bajubair%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Bajubair';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Neurology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Emergency Medicine',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Medical Consult',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Nephrology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Cardiology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Pulmonology / Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R2 Farid
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Farid%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Farid';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Endocrinology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Cardiology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'ICU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Medical Consult',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Nephrology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R2 Deema
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Deema%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Deema';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Medical Consult',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Endocrinology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Neurology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'ICU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Nephrology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R2 Samah
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Samah%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Samah';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'ICU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Medical Consult',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Endocrinology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Pulmonology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Gastroenterology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R2 Khalid
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Khalid%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Khalid';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Pulmonology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'ICU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Medical Consult',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Nephrology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Cardiology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R2 Bakur
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Bakur%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Bakur';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Neurology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Cardiology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Endocrinology / Neurology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Medical Consult',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Cardiology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R2 Shifa
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Shifa%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Shifa';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Pulmonology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Medical Consult',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Maternity Leave',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Maternity Leave',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R2 Waad
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Waad%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Waad';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Medical Consult',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'ICU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Neurology / Endocrinology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Nephrology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R1 Batool
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Batool%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Batool';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Neurology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Infectious Disease',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R1 Ghadeer
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Ghadeer%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Ghadeer';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Neurology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Gastroenterology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Gastroenterology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R1 Ahmed
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Ahmed%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Ahmed';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Cardiology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Gastroenterology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R1 Ibtihal
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Ibtihal%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Ibtihal';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Gastroenterology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Nephrology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Medical Consult',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R1 Abdulmajeed
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Abdulmajeed%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Abdulmajeed';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Annual Leave',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R1 Safa
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Safa%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Safa';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Nephrology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Gastroenterology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R1 Lamar
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Lamar%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Lamar';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Cardiology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Medical Consult',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Infectious Disease',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R1 Norah
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Norah%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Norah';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Cardiology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Gastroenterology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R1 Sumiah
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Sumiah%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Sumiah';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Cardiology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'Gastroenterology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R1 Ghufran
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Ghufran%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Ghufran';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Gastroenterology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Neurology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'Medical Consult',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R1 Abdulrahim
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Abdulrahim%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Abdulrahim';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Gastroenterology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'Annual Leave',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R1 Moh. Khalaf
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Moh.%' OR name ILIKE '%Khalaf%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Moh. Khalaf';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Nephrology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'Nephrology',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Cardiology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,6,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,7,'Infectious Disease',2,'start')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,8,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,9,'Gastroenterology',2,'end')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,10,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,11,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,12,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,13,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- R1 Boshra
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Boshra%' LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for resident: Boshra';
  ELSE
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,1,'Gastroenterology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,2,'Night Duty',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,3,'GIM/CTU',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,4,'Infectious Disease',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES (res_id,2025,5,'Nephrology',0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name, leave_weeks=EXCLUDED.leave_weeks, leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

COMMIT;

-- Verify: SELECT COUNT(*) FROM rotations WHERE academic_year=2025;
-- Expected: up to 520 rows (40 residents × 13 blocks, minus blank cells)