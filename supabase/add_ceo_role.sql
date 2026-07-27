-- Adds 'ceo' to the profiles.role check constraint, following the same
-- pattern as the 'dio' role (Dr. Arwa Jamal). CEO account (Dr. Sohail
-- Bajammal) gets PD-level access via effectiveRole()/isPdRole() in the
-- frontend, displayed as "CEO" instead of "Program Director".
-- Run this once in the Supabase SQL Editor.

ALTER TABLE public.profiles DROP CONSTRAINT profiles_role_check;
ALTER TABLE public.profiles ADD CONSTRAINT profiles_role_check
  CHECK (role IN ('pd','deputy_pd','chief','consultant','resident','dio','ceo'));
