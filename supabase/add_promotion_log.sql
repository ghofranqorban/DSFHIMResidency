-- Promotion log table — tracks annual level promotions per academic year
-- Run once in Supabase SQL editor

CREATE TABLE IF NOT EXISTS promotion_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  academic_year integer NOT NULL UNIQUE,
  promoted_at timestamptz NOT NULL DEFAULT now(),
  promoted_by uuid REFERENCES auth.users(id),
  changes jsonb
);

ALTER TABLE promotion_log ENABLE ROW LEVEL SECURITY;

-- PD and chief can read; PD can insert
CREATE POLICY promotion_log_select ON promotion_log
  FOR SELECT TO authenticated USING (true);

CREATE POLICY promotion_log_insert ON promotion_log
  FOR INSERT TO authenticated WITH CHECK (true);
