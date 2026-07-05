-- DSFH Residency Portal — Migration 002
-- Adds a self-editable "contact email" field to each account (separate from
-- the internal @dsfh.local login username, which never changes).
-- Run this once in the Supabase SQL editor (Project > SQL Editor > New query),
-- the same place you ran schema.sql before. Safe to re-run.

alter table profiles add column if not exists contact_email text;

-- Security-definer function so any logged-in user can update ONLY their own
-- contact_email field (not any other column, and not anyone else's row).
create or replace function update_my_contact_email(new_email text)
returns void
language plpgsql security definer set search_path = public as $$
begin
  update profiles set contact_email = new_email where id = auth.uid();
end;
$$;
