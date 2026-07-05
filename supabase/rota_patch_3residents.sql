-- ============================================================
-- ROTA PATCH — Omar B (R4), Omar H (R3), Rowidh/Rowaid (R3)
-- These three had single-letter initials that caused wrong DB
-- name matches in the original import. Run this AFTER checking
-- the diagnostic query below.
-- ============================================================

-- ─── STEP 1: Run this SELECT first to see exact names in your DB ─────────────
-- SELECT id, name FROM residents
-- WHERE name ILIKE '%Omar%' OR name ILIKE '%Rowid%' OR name ILIKE '%Ruwaid%' OR name ILIKE '%Rawaid%';
-- Then confirm the IDs and names look right before running Step 2.
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;

-- ─────────────────────────────────────────────────────────────────────────────
-- R4  Omar B  (Gastro, CTU, Cardio, Night, CTU, Clinic, Endo, Rheuma,
--              Pulmo, Clinic, Elective, Elective, Annual Leave)
-- ─────────────────────────────────────────────────────────────────────────────
DO $$
DECLARE res_id bigint;
BEGIN
  -- Try full-phrase first ("Omar B" covers "Dr. Omar Bakr", "Dr. Omar Banafea", etc.)
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Omar B%' LIMIT 1;
  -- Fallback: any Omar that is NOT Omar H
  IF res_id IS NULL THEN
    SELECT id INTO res_id FROM residents
    WHERE name ILIKE '%Omar%' AND name NOT ILIKE '%Omar H%' LIMIT 1;
  END IF;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for: Omar B — please edit the ILIKE pattern above with the exact DB name';
  ELSE
    RAISE NOTICE 'Omar B matched resident id=%', res_id;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES
        (res_id,2025, 1,'Gastroenterology'    ,0,'none'),
        (res_id,2025, 2,'GIM/CTU'             ,0,'none'),
        (res_id,2025, 3,'Cardiology'          ,0,'none'),
        (res_id,2025, 4,'Night Duty'          ,0,'none'),
        (res_id,2025, 5,'GIM/CTU'             ,0,'none'),
        (res_id,2025, 6,'Outpatient Clinic'   ,0,'none'),
        (res_id,2025, 7,'Endocrinology'       ,0,'none'),
        (res_id,2025, 8,'Rheumatology'        ,0,'none'),
        (res_id,2025, 9,'Pulmonology'         ,0,'none'),
        (res_id,2025,10,'Outpatient Clinic'   ,0,'none'),
        (res_id,2025,11,'Elective'            ,0,'none'),
        (res_id,2025,12,'Elective'            ,0,'none'),
        (res_id,2025,13,'Annual Leave'        ,0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name,
            leave_weeks=EXCLUDED.leave_weeks,
            leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- ─────────────────────────────────────────────────────────────────────────────
-- R3  Omar H  (ER, Pulmo, CTU, Cardio, Hema/2wks, ID, ICU, Night,
--              Nephro, Gastro/2wks, Night, Onco, CTU)
-- ─────────────────────────────────────────────────────────────────────────────
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents WHERE name ILIKE '%Omar H%' LIMIT 1;
  IF res_id IS NULL THEN
    SELECT id INTO res_id FROM residents
    WHERE name ILIKE '%Omar%' AND name NOT ILIKE '%Omar B%' LIMIT 1;
  END IF;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for: Omar H — please edit the ILIKE pattern above with the exact DB name';
  ELSE
    RAISE NOTICE 'Omar H matched resident id=%', res_id;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES
        (res_id,2025, 1,'Emergency Medicine'  ,0,'none'),
        (res_id,2025, 2,'Pulmonology'         ,0,'none'),
        (res_id,2025, 3,'GIM/CTU'             ,0,'none'),
        (res_id,2025, 4,'Cardiology'          ,0,'none'),
        (res_id,2025, 5,'Hematology'          ,2,'end' ),   -- Hema/2wks
        (res_id,2025, 6,'Infectious Disease'  ,0,'none'),
        (res_id,2025, 7,'ICU'                 ,0,'none'),
        (res_id,2025, 8,'Night Duty'          ,0,'none'),
        (res_id,2025, 9,'Nephrology'          ,0,'none'),
        (res_id,2025,10,'Gastroenterology'    ,2,'end' ),   -- Gastro/2wks
        (res_id,2025,11,'Night Duty'          ,0,'none'),
        (res_id,2025,12,'Oncology'            ,0,'none'),
        (res_id,2025,13,'GIM/CTU'             ,0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name,
            leave_weeks=EXCLUDED.leave_weeks,
            leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

-- ─────────────────────────────────────────────────────────────────────────────
-- R3  Rowidh / Rowaid / Ruwaid  (Rheuma, ID, Gastro, ER, Night,
--     2wks/Onco, CTU, ICU, Cardio, 2wks/Nephro, CTU, Pulmo, Night)
-- ─────────────────────────────────────────────────────────────────────────────
DO $$
DECLARE res_id bigint;
BEGIN
  SELECT id INTO res_id FROM residents
  WHERE name ILIKE '%Rowid%' OR name ILIKE '%Ruwaid%' OR name ILIKE '%Rawaid%'
     OR name ILIKE '%Rowaida%' OR name ILIKE '%Rouwaida%'
  LIMIT 1;
  IF res_id IS NULL THEN
    RAISE NOTICE 'No match for: Rowidh/Rowaid — please edit the ILIKE pattern above with the exact DB name';
  ELSE
    RAISE NOTICE 'Rowidh matched resident id=%', res_id;
    INSERT INTO rotations (resident_id,academic_year,block_number,rotation_name,leave_weeks,leave_position)
      VALUES
        (res_id,2025, 1,'Rheumatology'        ,0,'none'),
        (res_id,2025, 2,'Infectious Disease'  ,0,'none'),
        (res_id,2025, 3,'Gastroenterology'    ,0,'none'),
        (res_id,2025, 4,'Emergency Medicine'  ,0,'none'),
        (res_id,2025, 5,'Night Duty'          ,0,'none'),
        (res_id,2025, 6,'Oncology'            ,2,'start'),  -- 2wks/Onco
        (res_id,2025, 7,'GIM/CTU'             ,0,'none'),
        (res_id,2025, 8,'ICU'                 ,0,'none'),
        (res_id,2025, 9,'Cardiology'          ,0,'none'),
        (res_id,2025,10,'Nephrology'          ,2,'start'),  -- 2wks/Nephro
        (res_id,2025,11,'GIM/CTU'             ,0,'none'),
        (res_id,2025,12,'Pulmonology'         ,0,'none'),
        (res_id,2025,13,'Night Duty'          ,0,'none')
      ON CONFLICT (resident_id,academic_year,block_number) DO UPDATE
        SET rotation_name=EXCLUDED.rotation_name,
            leave_weeks=EXCLUDED.leave_weeks,
            leave_position=EXCLUDED.leave_position;
  END IF;
END $$;

COMMIT;

-- ─── Verify ──────────────────────────────────────────────────────────────────
-- SELECT r.name, ro.block_number, ro.rotation_name
-- FROM rotations ro JOIN residents r ON r.id=ro.resident_id
-- WHERE ro.academic_year=2025
--   AND (r.name ILIKE '%Omar%' OR r.name ILIKE '%Rowid%' OR r.name ILIKE '%Ruwaid%')
-- ORDER BY r.name, ro.block_number;
