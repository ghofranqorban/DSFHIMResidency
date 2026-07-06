-- Add resident_name column to oncall_schedule for outside rotators / free-text entries
-- Run this in Supabase SQL Editor

ALTER TABLE public.oncall_schedule
  ADD COLUMN IF NOT EXISTS resident_name text;
