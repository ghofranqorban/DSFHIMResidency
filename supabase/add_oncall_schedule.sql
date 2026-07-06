-- ============================================================
-- On-Call Schedule table
-- Run in Supabase SQL Editor
-- ============================================================

CREATE TABLE IF NOT EXISTS public.oncall_schedule (
  id              uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  block_number    integer     NOT NULL,
  academic_year   integer     NOT NULL,
  schedule_date   date        NOT NULL,
  slot_key        text        NOT NULL,
  resident_id     bigint      REFERENCES public.residents(id) ON DELETE CASCADE,
  is_extra        boolean     DEFAULT false,
  created_by      uuid        REFERENCES public.profiles(id),
  created_at      timestamptz DEFAULT now(),
  CONSTRAINT oncall_slot_key_check CHECK (
    slot_key IN ('er_medical','bldg1','bldg2','consult','ctu1','ctu2')
  ),
  UNIQUE (schedule_date, slot_key)
);

-- Indexes
CREATE INDEX IF NOT EXISTS oncall_schedule_block_idx    ON public.oncall_schedule(academic_year, block_number);
CREATE INDEX IF NOT EXISTS oncall_schedule_date_idx     ON public.oncall_schedule(schedule_date);
CREATE INDEX IF NOT EXISTS oncall_schedule_resident_idx ON public.oncall_schedule(resident_id);

-- Row-level security
ALTER TABLE public.oncall_schedule ENABLE ROW LEVEL SECURITY;

-- All authenticated users can read
CREATE POLICY "authenticated can read oncall_schedule"
  ON public.oncall_schedule FOR SELECT
  TO authenticated USING (true);

-- PD, deputy_pd, chief, and privileged accounts can write
CREATE POLICY "oncall editors can write oncall_schedule"
  ON public.oncall_schedule FOR ALL
  TO authenticated
  USING (
    (SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('pd','deputy_pd','chief')
    OR EXISTS (
      SELECT 1 FROM public.account_privileges
      WHERE profile_id = auth.uid() AND privilege_key = 'edit_oncall'
    )
  )
  WITH CHECK (
    (SELECT role FROM public.profiles WHERE id = auth.uid()) IN ('pd','deputy_pd','chief')
    OR EXISTS (
      SELECT 1 FROM public.account_privileges
      WHERE profile_id = auth.uid() AND privilege_key = 'edit_oncall'
    )
  );
