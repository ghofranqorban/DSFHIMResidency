-- ─── Chief Resident designation ────────────────────────────────────────────
-- Run once in Supabase SQL Editor.
-- Adds a nullable chief_role column to residents.
-- Values: NULL (normal), 'chief' (Chief Resident), 'cochief' (Co-Chief Resident).
-- Only one resident should have each value at a time — enforced by the
-- setChiefRole() function in the frontend (it clears the previous holder first).

ALTER TABLE residents ADD COLUMN IF NOT EXISTS chief_role TEXT
  CHECK (chief_role IN ('chief','cochief'));

-- Verify
-- SELECT id, name, chief_role FROM residents WHERE chief_role IS NOT NULL;
