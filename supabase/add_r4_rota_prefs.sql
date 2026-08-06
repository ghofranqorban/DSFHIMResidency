-- R4 Rotation Preferences (Elective + Clinic block picks for upcoming R4s)
-- Run in Supabase SQL Editor

-- Preferences (one row per resident per year)
CREATE TABLE IF NOT EXISTS r4_rota_prefs (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  resident_id bigint NOT NULL REFERENCES residents(id),
  academic_year int NOT NULL,
  elective1_block int,
  elective1_subspecialty text,
  elective1_location text,
  elective2_block int,
  elective2_subspecialty text,
  elective2_location text,
  clinic1_block int,
  clinic2_block int,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','submitted')),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(resident_id, academic_year)
);

-- Open/close window (same pattern as gim_rota_status)
CREATE TABLE IF NOT EXISTS r4_prefs_status (
  academic_year int PRIMARY KEY,
  is_open boolean NOT NULL DEFAULT false,
  opened_at timestamptz,
  deadline timestamptz
);

-- RLS
ALTER TABLE r4_rota_prefs ENABLE ROW LEVEL SECURITY;
ALTER TABLE r4_prefs_status ENABLE ROW LEVEL SECURITY;

-- r4_prefs_status: all auth read, PD/chief/plan_rota write
CREATE POLICY "r4_prefs_status_read" ON r4_prefs_status
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "r4_prefs_status_write" ON r4_prefs_status
  FOR INSERT TO authenticated WITH CHECK (
    is_pd_or_chief() OR has_priv('plan_rota')
  );
CREATE POLICY "r4_prefs_status_update" ON r4_prefs_status
  FOR UPDATE TO authenticated USING (
    is_pd_or_chief() OR has_priv('plan_rota')
  ) WITH CHECK (
    is_pd_or_chief() OR has_priv('plan_rota')
  );

-- r4_rota_prefs: all auth read, own row insert/update (+ PD override)
CREATE POLICY "r4_prefs_read" ON r4_rota_prefs
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "r4_prefs_insert" ON r4_rota_prefs
  FOR INSERT TO authenticated WITH CHECK (
    resident_id = app_resident_id() OR is_pd_or_chief()
  );
CREATE POLICY "r4_prefs_update" ON r4_rota_prefs
  FOR UPDATE TO authenticated USING (
    resident_id = app_resident_id() OR is_pd_or_chief()
  ) WITH CHECK (
    resident_id = app_resident_id() OR is_pd_or_chief()
  );
