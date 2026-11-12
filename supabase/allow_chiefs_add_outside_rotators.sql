-- Let the Chief and Co-Chief add outside rotators from the rota builder.
--
-- Adds one INSERT policy on residents that accepts a row ONLY when it is marked
-- outside_rotator. Policies OR together, so the PD's existing rights are unchanged, and
-- through this policy a chief can never add, edit or remove a programme resident.
-- Run after add_outside_rotators.sql. Safe to run more than once.

-- Who counts: a login whose profile role is 'chief', or whose resident record carries
-- chief_role 'chief' or 'cochief' (the Co-Chief is usually an ordinary resident login).
-- security definer so it can read profiles/residents without tripping their own policies.
create or replace function public.is_chief_or_cochief() returns boolean
language sql stable security definer set search_path = public as $$
  select exists(
    select 1 from profiles p
    left join residents r on r.id = p.resident_id
    where p.id = auth.uid()
      and (p.role = 'chief' or r.chief_role in ('chief','cochief'))
  );
$$;
revoke all on function public.is_chief_or_cochief() from public;
grant execute on function public.is_chief_or_cochief() to authenticated;

drop policy if exists residents_insert_outside_by_chiefs on public.residents;
create policy residents_insert_outside_by_chiefs on public.residents
  for insert to authenticated
  with check (outside_rotator = true and public.is_chief_or_cochief());

-- Check 1: the policies now on residents (the new one should be listed).
select policyname, cmd, roles, with_check
from pg_policies where schemaname = 'public' and tablename = 'residents'
order by policyname;

-- Check 2: who the new rule lets in. Expect the Chief and the Co-Chief only.
select p.username, p.role, r.name, r.chief_role
from profiles p left join residents r on r.id = p.resident_id
where p.role = 'chief' or r.chief_role in ('chief','cochief');
