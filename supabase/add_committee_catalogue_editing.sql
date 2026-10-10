-- Committee catalogue editing: keep seat records in step when a committee is renamed.
-- Run in the Supabase SQL editor. Idempotent.
--
-- committee_memberships stores a COPY of the committee's name (committee_name), because the older
-- CanMEDS pages and the committee_summary view read that text. The portal can now rename a
-- committee, so a trigger rewrites that copy for every seat of the renamed committee. Without it a
-- rename would leave old seats under the old name.
--
-- Who may add, rename, recolour, reorder or retire a committee is unchanged and already in the
-- database: committees_write (pd, deputy_pd) and committees_manage_priv (manage_committees).
--
-- Do NOT re-run the seed block of add_committees.sql after committees have been edited in the
-- portal: its "on conflict do update" would put the original names, colours and order back.

create or replace function public.committee_rename_cascade()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.name is distinct from old.name then
    update public.committee_memberships
       set committee_name = new.name
     where committee_id = new.id
       and committee_name is distinct from new.name;
  end if;
  return new;
end $$;

revoke all on function public.committee_rename_cascade() from public;

drop trigger if exists committees_rename_cascade_t on public.committees;
create trigger committees_rename_cascade_t
  after update of name on public.committees
  for each row execute function public.committee_rename_cascade();

-- Check: one trigger on committees.
select event_object_table as on_table, trigger_name, event_manipulation
  from information_schema.triggers
 where trigger_schema = 'public' and trigger_name = 'committees_rename_cascade_t';
