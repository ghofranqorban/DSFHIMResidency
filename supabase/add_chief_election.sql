-- Chief Resident Election
-- Run in Supabase SQL Editor

-- Election config (PD sets nomination/voting windows)
CREATE TABLE IF NOT EXISTS chief_election (
  academic_year int PRIMARY KEY,
  nomination_start timestamptz,
  nomination_end timestamptz,
  voting_start timestamptz,
  voting_end timestamptz,
  created_at timestamptz DEFAULT now()
);

-- Self-nominations (R2/R3 nominate themselves)
CREATE TABLE IF NOT EXISTS chief_nominations (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  resident_id bigint NOT NULL REFERENCES residents(id),
  academic_year int NOT NULL,
  nominated_at timestamptz DEFAULT now(),
  UNIQUE(resident_id, academic_year)
);

-- Votes (one per voter per election)
CREATE TABLE IF NOT EXISTS chief_votes (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  voter_profile_id uuid NOT NULL REFERENCES profiles(id),
  candidate_resident_id bigint NOT NULL REFERENCES residents(id),
  academic_year int NOT NULL,
  voted_at timestamptz DEFAULT now(),
  UNIQUE(voter_profile_id, academic_year)
);

-- RLS
ALTER TABLE chief_election ENABLE ROW LEVEL SECURITY;
ALTER TABLE chief_nominations ENABLE ROW LEVEL SECURITY;
ALTER TABLE chief_votes ENABLE ROW LEVEL SECURITY;

-- chief_election: all auth read, PD/chief write
CREATE POLICY "chief_election_read" ON chief_election
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "chief_election_write" ON chief_election
  FOR INSERT TO authenticated WITH CHECK (is_pd_or_chief());
CREATE POLICY "chief_election_update" ON chief_election
  FOR UPDATE TO authenticated USING (is_pd_or_chief()) WITH CHECK (is_pd_or_chief());

-- chief_nominations: all auth read (see candidates), own row insert/delete
CREATE POLICY "chief_nominations_read" ON chief_nominations
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "chief_nominations_insert" ON chief_nominations
  FOR INSERT TO authenticated WITH CHECK (resident_id = app_resident_id());
CREATE POLICY "chief_nominations_delete" ON chief_nominations
  FOR DELETE TO authenticated USING (resident_id = app_resident_id() OR is_pd_or_chief());

-- chief_votes: PD/chief see all (for results), residents see only own vote
CREATE POLICY "chief_votes_read" ON chief_votes
  FOR SELECT TO authenticated USING (
    is_pd_or_chief() OR voter_profile_id = auth.uid()
  );
CREATE POLICY "chief_votes_insert" ON chief_votes
  FOR INSERT TO authenticated WITH CHECK (voter_profile_id = auth.uid());
-- No update/delete — votes are final
