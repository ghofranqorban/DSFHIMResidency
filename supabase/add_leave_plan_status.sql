-- Leave Plan — DB-backed submission deadline
--
-- Previously LP_DEADLINE was a hardcoded Date constant duplicated in two
-- places: the client (SFH_Residency_Portal.html) and the calendar edge
-- function (supabase/functions/ical/index.ts). Any future deadline change
-- required editing + redeploying both, with no guardrail if only one was
-- updated (same class of bug as the on-call slot-time mismatch fixed
-- earlier). This table becomes the single source of truth; both the client
-- and the edge function read the deadline from here.
--
-- Run in: Supabase > SQL Editor > New query. Safe to re-run.

CREATE TABLE IF NOT EXISTS public.leave_plan_status (
  academic_year int PRIMARY KEY,
  deadline timestamptz NOT NULL,
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE public.leave_plan_status ENABLE ROW LEVEL SECURITY;

CREATE POLICY "authenticated read leave_plan_status"
  ON public.leave_plan_status FOR SELECT
  TO authenticated USING (true);

CREATE POLICY "plan_rota holders write leave_plan_status"
  ON public.leave_plan_status FOR ALL
  TO authenticated
  USING (
    (SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('pd','deputy_pd','chief')
    OR has_priv('plan_rota')
  )
  WITH CHECK (
    (SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('pd','deputy_pd','chief')
    OR has_priv('plan_rota')
  );

-- Seed the current deadline so behavior is unchanged until an admin edits it.
INSERT INTO public.leave_plan_status (academic_year, deadline)
VALUES (2026, '2026-07-18T23:59:59+03:00')
ON CONFLICT (academic_year) DO NOTHING;
