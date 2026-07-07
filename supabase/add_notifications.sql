-- Notifications table: in-app bell notifications for residents and PD
-- Run in Supabase SQL Editor

CREATE TABLE IF NOT EXISTS public.notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
  type text NOT NULL DEFAULT 'info',
  message text NOT NULL,
  link_mod text,
  link_param text,
  read boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Users can only see their own notifications
CREATE POLICY "users_read_own_notifs"
  ON public.notifications FOR SELECT TO authenticated
  USING (profile_id = auth.uid());

-- Any authenticated user can create notifications (for cross-user alerts)
CREATE POLICY "auth_insert_notifs"
  ON public.notifications FOR INSERT TO authenticated
  WITH CHECK (true);

-- Users can update (mark read) their own notifications
CREATE POLICY "users_update_own_notifs"
  ON public.notifications FOR UPDATE TO authenticated
  USING (profile_id = auth.uid());

-- Users can delete their own notifications
CREATE POLICY "users_delete_own_notifs"
  ON public.notifications FOR DELETE TO authenticated
  USING (profile_id = auth.uid());

-- Index for fast per-user queries
CREATE INDEX IF NOT EXISTS notifications_profile_id_idx ON public.notifications(profile_id, created_at DESC);
