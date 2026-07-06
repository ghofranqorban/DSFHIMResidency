-- Best Resident — quarterly voting & winner tables
-- Run in Supabase SQL Editor

-- ── Votes ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.best_resident_votes (
  id              uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  profile_id      uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  academic_year   int  NOT NULL,
  quarter         int  NOT NULL CHECK (quarter BETWEEN 1 AND 4),
  voted_senior_id bigint REFERENCES public.residents(id) ON DELETE SET NULL,
  voted_junior_id bigint REFERENCES public.residents(id) ON DELETE SET NULL,
  created_at      timestamptz DEFAULT now(),
  UNIQUE(profile_id, academic_year, quarter)
);

ALTER TABLE public.best_resident_votes ENABLE ROW LEVEL SECURITY;

-- All authenticated users can read (for vote counts)
CREATE POLICY "auth read best_resident_votes"
  ON public.best_resident_votes FOR SELECT TO authenticated USING (true);

-- Users can insert their own vote
CREATE POLICY "auth insert own best_resident_vote"
  ON public.best_resident_votes FOR INSERT TO authenticated
  WITH CHECK (profile_id = auth.uid());

-- PD/deputy can delete (to reset voting)
CREATE POLICY "pd delete best_resident_votes"
  ON public.best_resident_votes FOR DELETE TO authenticated
  USING (app_role() IN ('pd','deputy_pd'));

-- ── Winners / voting status per quarter ────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.best_resident_winners (
  id                 uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  academic_year      int  NOT NULL,
  quarter            int  NOT NULL CHECK (quarter BETWEEN 1 AND 4),
  voting_open        bool DEFAULT false,
  voting_deadline    timestamptz,
  senior_resident_id bigint REFERENCES public.residents(id) ON DELETE SET NULL,
  junior_resident_id bigint REFERENCES public.residents(id) ON DELETE SET NULL,
  senior_score       numeric,
  junior_score       numeric,
  announced          bool DEFAULT false,
  announced_at       timestamptz,
  created_at         timestamptz DEFAULT now(),
  UNIQUE(academic_year, quarter)
);

ALTER TABLE public.best_resident_winners ENABLE ROW LEVEL SECURITY;

-- All authenticated users can read
CREATE POLICY "auth read best_resident_winners"
  ON public.best_resident_winners FOR SELECT TO authenticated USING (true);

-- PD/deputy can write
CREATE POLICY "pd write best_resident_winners"
  ON public.best_resident_winners FOR ALL TO authenticated
  USING (app_role() IN ('pd','deputy_pd'))
  WITH CHECK (app_role() IN ('pd','deputy_pd'));
