-- DSFH Residency Portal — fix_calendar_rls.sql
--
-- Root cause of "Invalid or expired calendar token" for non-PD/chief
-- residents: the profiles_write RLS policy (schema.sql) only allows
-- pd/chief roles to write to `profiles`, including their OWN row. So when a
-- regular resident tapped "Generate My Calendar Link", the UPDATE was
-- silently filtered out by RLS (no error returned by PostgREST), the UI
-- optimistically showed a token as if it worked, but it was never actually
-- saved to the database — the edge function then rejected it as unknown.
--
-- Fix: security-definer RPCs (same pattern as acknowledge_counseling) let
-- any authenticated user touch ONLY their own calendar_token/calendar_prefs
-- columns, nothing else on the profiles row.
--
-- Run once in the Supabase SQL editor. Safe to re-run.

create or replace function set_my_calendar_token(new_token text)
returns void
language plpgsql security definer set search_path = public as $$
begin
  update profiles set calendar_token = new_token where id = auth.uid();
end;
$$;

create or replace function set_my_calendar_prefs(new_prefs jsonb)
returns void
language plpgsql security definer set search_path = public as $$
begin
  update profiles set calendar_prefs = new_prefs where id = auth.uid();
end;
$$;

grant execute on function set_my_calendar_token(text) to authenticated;
grant execute on function set_my_calendar_prefs(jsonb) to authenticated;
