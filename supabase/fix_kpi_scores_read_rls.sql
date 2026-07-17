-- Allow ALL authenticated users to read kpi_scores.
-- Previously SELECT was restricted to PD/chief, a consultant's own mentees,
-- or the resident's own row (see add_kpi_scores.sql). That was fine while
-- kpi_scores was only used on PD/mentor-facing screens, but the Performance
-- Report (kpi_exec, added 6 Jul 2026) computes a portal-wide leaderboard for
-- every role including residents — calcKPI() reads the globally-cached
-- KPI_SCORES for every resident, not just the logged-in user's own. With the
-- old policy, a resident's session only received their own kpi_scores row,
-- so every other resident's Committee Score + 6 yearly bonus flags silently
-- collapsed to 0/false in that session's leaderboard math — producing a
-- different ranking/percentages depending on who's logged in.
--
-- Write access is unchanged (still PD/chief/assigned mentor only via
-- kpi_write). This mirrors the same all-authenticated-can-read pattern
-- already applied to rotations, mm_attendance, teaching_attendance, and
-- quiz_scores for the same reason.

DROP POLICY IF EXISTS "kpi_select" ON public.kpi_scores;
CREATE POLICY "kpi_select"
  ON public.kpi_scores FOR SELECT TO authenticated USING (true);
