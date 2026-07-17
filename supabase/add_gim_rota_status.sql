-- GIM Rotation Prefs — submission window control
-- Lets PD / plan_rota holders open and close the "Suggested GIM Rotations"
-- submission window from inside the portal (All Residents tab), with an
-- optional auto-close deadline — no more hardcoded GIM_OPEN flag in code.
-- Run in: Supabase > SQL Editor > New query. Safe to re-run.

CREATE TABLE IF NOT EXISTS public.gim_rota_status (
  academic_year int PRIMARY KEY,
  is_open boolean NOT NULL DEFAULT false,
  opened_at timestamptz,
  deadline timestamptz,
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE public.gim_rota_status ENABLE ROW LEVEL SECURITY;

CREATE POLICY "authenticated read gim_rota_status"
  ON public.gim_rota_status FOR SELECT
  TO authenticated USING (true);

CREATE POLICY "plan_rota holders write gim_rota_status"
  ON public.gim_rota_status FOR ALL
  TO authenticated
  USING (
    (SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('pd','deputy_pd','chief')
    OR has_priv('plan_rota')
  )
  WITH CHECK (
    (SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('pd','deputy_pd','chief')
    OR has_priv('plan_rota')
  );
