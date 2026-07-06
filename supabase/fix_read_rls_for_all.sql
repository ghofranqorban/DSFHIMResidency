-- Allow ALL authenticated users to read residents, consultants,
-- profiles, account_privileges, and oncall_schedule.
-- No role restrictions on reads — every logged-in user can see these.

-- residents
DROP POLICY IF EXISTS "residents read all authenticated" ON public.residents;
CREATE POLICY "residents read all authenticated"
  ON public.residents FOR SELECT TO authenticated USING (true);

-- consultants
DROP POLICY IF EXISTS "consultants read all authenticated" ON public.consultants;
CREATE POLICY "consultants read all authenticated"
  ON public.consultants FOR SELECT TO authenticated USING (true);

-- profiles
DROP POLICY IF EXISTS "profiles read all authenticated" ON public.profiles;
CREATE POLICY "profiles read all authenticated"
  ON public.profiles FOR SELECT TO authenticated USING (true);

-- account_privileges
DROP POLICY IF EXISTS "account_privileges read all authenticated" ON public.account_privileges;
CREATE POLICY "account_privileges read all authenticated"
  ON public.account_privileges FOR SELECT TO authenticated USING (true);

-- oncall_schedule
DROP POLICY IF EXISTS "oncall read all authenticated" ON public.oncall_schedule;
CREATE POLICY "oncall read all authenticated"
  ON public.oncall_schedule FOR SELECT TO authenticated USING (true);
