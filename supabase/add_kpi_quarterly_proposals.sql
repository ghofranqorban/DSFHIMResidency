-- ─── KPI Quarterly & Proposals migration ───────────────────────────────────
-- Run this in the Supabase SQL editor.

-- 1. Add new yearly KPI columns to kpi_scores
ALTER TABLE kpi_scores
  ADD COLUMN IF NOT EXISTS awards_honors     boolean DEFAULT false,
  ADD COLUMN IF NOT EXISTS volunteering      boolean DEFAULT false;

-- 2. Quarterly mentor milestones per resident per quarter
CREATE TABLE IF NOT EXISTS kpi_quarterly (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  resident_id          integer NOT NULL REFERENCES residents(id) ON DELETE CASCADE,
  academic_year        integer NOT NULL,
  quarter              integer NOT NULL CHECK (quarter BETWEEN 1 AND 4),
  research_milestone   text,
  research_achieved    boolean DEFAULT false,
  improvement_area     text,
  improvement_achieved boolean DEFAULT false,
  set_by               uuid REFERENCES profiles(id),
  updated_at           timestamptz DEFAULT now(),
  UNIQUE(resident_id, academic_year, quarter)
);

ALTER TABLE kpi_quarterly ENABLE ROW LEVEL SECURITY;

CREATE POLICY "kpi_quarterly_select" ON kpi_quarterly
  FOR SELECT USING (true); -- all authenticated users can read

CREATE POLICY "kpi_quarterly_insert_update" ON kpi_quarterly
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM profiles WHERE id = auth.uid()
        AND role IN ('pd','deputy_pd','chief','consultant')
    )
  );

-- 3. KPI proposals: anyone can submit, PD approves
CREATE TABLE IF NOT EXISTS kpi_proposals (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  resident_id      integer NOT NULL REFERENCES residents(id) ON DELETE CASCADE,
  academic_year    integer NOT NULL,
  quarter          integer,           -- null = yearly item, 1-4 = quarterly
  field_key        text NOT NULL,     -- 'publication','oral','poster','qi','awards','volunteering','research_achieved','improvement_achieved'
  note             text,
  proposed_by      uuid REFERENCES profiles(id),
  proposed_by_role text,              -- 'resident','consultant','chief','pd'
  proposed_at      timestamptz DEFAULT now(),
  status           text DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected')),
  reviewed_by      uuid REFERENCES profiles(id),
  reviewed_at      timestamptz
);

ALTER TABLE kpi_proposals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "kpi_proposals_select" ON kpi_proposals
  FOR SELECT USING (true);

CREATE POLICY "kpi_proposals_insert" ON kpi_proposals
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "kpi_proposals_update_pd" ON kpi_proposals
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM profiles WHERE id = auth.uid()
        AND role IN ('pd','deputy_pd')
    )
  );
