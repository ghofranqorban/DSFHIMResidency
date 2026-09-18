-- ============================================================
-- On-Call Preference Survey
--
-- Each active resident names dates they would prefer NOT to be on call
-- for one block: 2 weekend days (any 2 of the block's Fri/Sat days, they
-- do not have to be the same weekend) + 4 weekdays.
--
-- These are PREFERENCES, not blocks. The on-call builder flags a clash and
-- still lets the scheduler assign over it.
--
-- One row per picked date, rather than 6 columns, so the builder can join
-- straight on the date it is rendering instead of unpivoting per resident.
--
-- Run in the Supabase SQL Editor.
-- ============================================================

CREATE TABLE IF NOT EXISTS oncall_prefs (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  resident_id bigint NOT NULL REFERENCES residents(id),
  academic_year int NOT NULL,
  block_number int NOT NULL,
  pref_date date NOT NULL,
  -- Which quota this pick came out of. Stored rather than derived from the
  -- weekday, because the Fri/Sat definition lives in the client and a future
  -- change there must not silently re-bucket rows already on file.
  kind text NOT NULL CHECK (kind IN ('weekend','weekday')),
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','submitted')),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(resident_id, academic_year, block_number, pref_date)
);

-- The builder reads every resident's picks for one block at a time.
CREATE INDEX IF NOT EXISTS oncall_prefs_block_idx
  ON oncall_prefs (academic_year, block_number);

-- Open/close window, per block. Same pattern as gim_rota_status /
-- r4_prefs_status, but keyed by block too: this survey runs once per block,
-- not once per year.
CREATE TABLE IF NOT EXISTS oncall_prefs_status (
  academic_year int NOT NULL,
  block_number int NOT NULL,
  is_open boolean NOT NULL DEFAULT false,
  opened_at timestamptz,
  deadline timestamptz,
  PRIMARY KEY (academic_year, block_number)
);

-- ── RLS ─────────────────────────────────────────────────────
ALTER TABLE oncall_prefs ENABLE ROW LEVEL SECURITY;
ALTER TABLE oncall_prefs_status ENABLE ROW LEVEL SECURITY;

-- "Who may run the on-call survey" must be the same set as "who may edit the
-- on-call schedule", so this repeats oncall_schedule's test rather than using
-- is_pd_or_chief(), which is pd/chief only and would drop deputy_pd.
CREATE OR REPLACE FUNCTION oncall_can_edit() RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT app_role() IN ('pd','deputy_pd','chief') OR has_priv('edit_oncall');
$$;

-- Window: everyone reads, schedulers write.
CREATE POLICY "oncall_prefs_status_read" ON oncall_prefs_status
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "oncall_prefs_status_insert" ON oncall_prefs_status
  FOR INSERT TO authenticated WITH CHECK ( oncall_can_edit() );
CREATE POLICY "oncall_prefs_status_update" ON oncall_prefs_status
  FOR UPDATE TO authenticated USING ( oncall_can_edit() )
  WITH CHECK ( oncall_can_edit() );

-- Picks: all authenticated read — the builder needs every resident's picks to
-- flag clashes, and the demand tally counts across the whole cohort. This does
-- mean residents can see each other's picks, same as r4_rota_prefs.
CREATE POLICY "oncall_prefs_read" ON oncall_prefs
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "oncall_prefs_insert" ON oncall_prefs
  FOR INSERT TO authenticated WITH CHECK (
    resident_id = app_resident_id() OR oncall_can_edit()
  );
CREATE POLICY "oncall_prefs_update" ON oncall_prefs
  FOR UPDATE TO authenticated USING (
    resident_id = app_resident_id() OR oncall_can_edit()
  ) WITH CHECK (
    resident_id = app_resident_id() OR oncall_can_edit()
  );
-- DELETE is required, not optional: saving a changed set replaces the
-- resident's rows for that block rather than diffing them.
CREATE POLICY "oncall_prefs_delete" ON oncall_prefs
  FOR DELETE TO authenticated USING (
    resident_id = app_resident_id() OR oncall_can_edit()
  );

-- ── VERIFY ──────────────────────────────────────────────────
-- Expect both tables listed, and 8 policies total.
SELECT tablename, policyname, cmd
FROM pg_policies
WHERE tablename IN ('oncall_prefs','oncall_prefs_status')
ORDER BY tablename, cmd, policyname;
