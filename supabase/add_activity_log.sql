-- Activity log table: immutable audit trail of who did what and when
-- Run in Supabase SQL Editor

CREATE TABLE IF NOT EXISTS public.activity_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  display_name text,
  action_type text NOT NULL,
  entity_type text,
  entity_id text,
  details jsonb NOT NULL DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.activity_log ENABLE ROW LEVEL SECURITY;

-- PD, deputy PD, chief, and DIO can read all log entries
CREATE POLICY "pd_read_activity_log"
  ON public.activity_log FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
      AND role IN ('pd', 'deputy_pd', 'chief', 'dio')
    )
  );

-- Any authenticated user can insert log entries
CREATE POLICY "auth_insert_activity_log"
  ON public.activity_log FOR INSERT TO authenticated
  WITH CHECK (profile_id = auth.uid());

-- No updates or deletes (immutable audit trail)

-- Index for fast time-ordered queries
CREATE INDEX IF NOT EXISTS activity_log_created_at_idx ON public.activity_log(created_at DESC);
CREATE INDEX IF NOT EXISTS activity_log_profile_id_idx ON public.activity_log(profile_id);
