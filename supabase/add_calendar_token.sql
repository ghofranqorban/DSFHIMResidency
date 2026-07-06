-- Add live calendar subscription fields to profiles
-- Run in Supabase SQL Editor (Dashboard > SQL Editor > New query)

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS calendar_token text UNIQUE DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS calendar_prefs jsonb DEFAULT '{"rota":true,"oncall":true,"mm":true,"teach":false,"deadlines":true}'::jsonb;

-- Fast lookup by token (edge function queries this on every calendar refresh)
CREATE INDEX IF NOT EXISTS profiles_calendar_token_idx
  ON public.profiles(calendar_token)
  WHERE calendar_token IS NOT NULL;
