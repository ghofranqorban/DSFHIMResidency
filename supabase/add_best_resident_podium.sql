-- ============================================================================
-- Stars / Best Resident: save the top three of each category with the winners.
--
-- When the PD locks the winners, the portal saves a snapshot next to them: the first three
-- residents of each category, their final score, KPI percentage, and how many votes each
-- received from residents, consultants and nurses, with the number each group cast. The Hall of
-- Fame draws from this snapshot, so it never changes afterwards, whatever happens to the
-- roster or the October promotions.
--
-- After this file:
--   * best_resident_winners has a nullable jsonb column, podium. Quarters announced before
--     this file keep it null and show the old winners-only card.
--   * While a quarter's winners are sealed (announced, but the announcement time has not
--     come), best_resident_status() blanks podium for everyone but the PD and deputy, in the
--     same way it already blanks the winners. The table's own read rule already hides a
--     sealed row from everyone else.
--
-- Changes no existing data. Safe to re-run. Run in the Supabase SQL Editor.
-- ============================================================================

do $$
begin
  if to_regprocedure('public.br_is_lead()') is null
     or to_regclass('public.best_resident_winners') is null then
    raise exception 'The Stars sealing migration (add_best_resident_sealing.sql) has not been run. Nothing has been changed.';
  end if;
end $$;

alter table public.best_resident_winners
  add column if not exists podium jsonb;

-- Same function as in add_best_resident_sealing.sql, with podium blanked alongside the winners.
create or replace function best_resident_status()
returns jsonb
language sql stable security definer set search_path = public
as $$
  select jsonb_build_object(
    'now',  now(),
    'rows', coalesce(jsonb_agg(
      case
        when br_is_lead()
          or not (coalesce(w.announced, false) and w.announced_at is not null and w.announced_at > now())
        then to_jsonb(w)
        else to_jsonb(w) || jsonb_build_object(
               'senior_resident_id', null, 'junior_resident_id', null,
               'senior_score',       null, 'junior_score',       null,
               'podium',             null)
      end
      order by w.academic_year, w.quarter), '[]'::jsonb))
  from best_resident_winners w;
$$;

revoke all on function best_resident_status() from public;
grant execute on function best_resident_status() to authenticated;

-- Check: expect one row, podium, jsonb.
select column_name, data_type
from information_schema.columns
where table_schema = 'public' and table_name = 'best_resident_winners' and column_name = 'podium';
