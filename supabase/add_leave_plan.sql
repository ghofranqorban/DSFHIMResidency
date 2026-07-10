-- Annual Leave Plan for AY 2026-27
-- Stores each resident's two chosen 2-week leave periods (planning only, separate from leave_records)

CREATE TABLE IF NOT EXISTS public.leave_plan (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  resident_id bigint NOT NULL REFERENCES public.residents(id) ON DELETE CASCADE,
  academic_year int NOT NULL DEFAULT 2026,
  first_leave_key text,
  first_leave_block int,
  first_leave_half text CHECK (first_leave_half IN ('first','second')),
  first_leave_from date,
  first_leave_to date,
  second_leave_key text,
  second_leave_block int,
  second_leave_half text CHECK (second_leave_half IN ('first','second')),
  second_leave_from date,
  second_leave_to date,
  note text,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','submitted')),
  submitted_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(resident_id, academic_year)
);

ALTER TABLE public.leave_plan ENABLE ROW LEVEL SECURITY;

-- All authenticated users can read (JS handles display restrictions)
CREATE POLICY "authenticated read leave_plan"
  ON public.leave_plan FOR SELECT
  TO authenticated USING (true);

-- Residents write own row; PD/deputy_pd/chief/dio write any row
CREATE POLICY "write leave_plan"
  ON public.leave_plan FOR ALL
  TO authenticated
  USING (
    resident_id = app_resident_id()
    OR (SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('pd','deputy_pd','chief','dio')
  )
  WITH CHECK (
    resident_id = app_resident_id()
    OR (SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('pd','deputy_pd','chief','dio')
  );
