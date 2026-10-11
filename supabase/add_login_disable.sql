-- Disable / enable a login from PD Admin Panel > Accounts.
-- Run in the Supabase SQL editor. Idempotent.
--
-- The actual lock is on the auth user (banned_until), set by the bright-processor edge function
-- with the service key; this column mirrors it on the profile so the portal can show "Login
-- disabled" and refuse a stale session without needing auth.users, which the browser cannot read.
-- Written only by the edge function (service role); readable like the rest of profiles.

alter table public.profiles add column if not exists login_disabled_at timestamptz;

select column_name, data_type from information_schema.columns
 where table_schema = 'public' and table_name = 'profiles' and column_name = 'login_disabled_at';
