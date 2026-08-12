-- Chief Resident Election — publish results to all residents
-- Run in Supabase SQL Editor

-- Residents can only SELECT their own row from chief_votes (see add_chief_election.sql),
-- so a resident's browser cannot compute the tally. Widening that policy is not an option:
-- voter_profile_id lives on those rows, so any resident could derive who voted for whom.
-- Instead the PD's session computes the final counts at publish time and freezes them here,
-- on a table every authenticated user can already read.
ALTER TABLE chief_election ADD COLUMN IF NOT EXISTS results_published boolean NOT NULL DEFAULT false;
ALTER TABLE chief_election ADD COLUMN IF NOT EXISTS results_published_at timestamptz;
ALTER TABLE chief_election ADD COLUMN IF NOT EXISTS results_snapshot jsonb;

-- results_snapshot shape:
-- {
--   "winner_resident_id": 12,
--   "total_votes": 31,
--   "eligible_voters": 40,
--   "candidates": [ {"resident_id":12,"votes":17}, {"resident_id":8,"votes":9} ]
-- }
-- Resident names/levels are resolved client-side from RESIDENTS, not stored here.

-- Existing chief_election policies already cover this:
--   chief_election_read   -> SELECT to authenticated USING (true)
--   chief_election_update -> UPDATE gated on is_pd_or_chief()
-- so no policy changes are needed.
