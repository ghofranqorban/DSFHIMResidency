-- GIM Rotation Preferences for AY 2026-27
-- Lets each resident suggest which blocks (1-13) they'd prefer for their
-- General Internal Medicine coverage (CTU / Night Float / ER Team — the PD
-- decides which type goes where). Purely a non-binding suggestion to help
-- build the master rota; no cap/lock logic like leave_plan has.
-- Run in: Supabase > SQL Editor > New query. Safe to re-run.

CREATE TABLE IF NOT EXISTS public.gim_rota_prefs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  resident_id bigint NOT NULL REFERENCES public.residents(id) ON DELETE CASCADE,
  academic_year int NOT NULL DEFAULT 2026,
  blocks jsonb NOT NULL DEFAULT '[]'::jsonb,
  note text,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','submitted')),
  submitted_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(resident_id, academic_year)
);

ALTER TABLE public.gim_rota_prefs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "authenticated read gim_rota_prefs"
  ON public.gim_rota_prefs FOR SELECT
  TO authenticated USING (true);

CREATE POLICY "write gim_rota_prefs"
  ON public.gim_rota_prefs FOR ALL
  TO authenticated
  USING (
    resident_id = app_resident_id()
    OR (SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('pd','deputy_pd','chief','dio')
  )
  WITH CHECK (
    resident_id = app_resident_id()
    OR (SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('pd','deputy_pd','chief','dio')
  );
