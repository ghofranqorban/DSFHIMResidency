-- DSFH Residency Portal — remember which rota_plan cells the bulk prefill wrote
-- Run in: Supabase → SQL Editor → New query. Safe to re-run.
--
-- The rota builder's "Prefill from approved plans" used to refuse any non-empty
-- cell, so a second run could not correct itself: if an approved leave moved to a
-- different block, or was withdrawn, the cell the first run wrote stayed behind as
-- a stale copy and the new block was filled beside it.
--
-- Re-running now clears the previous run first. That is only safe if the prefill
-- can tell its own rows apart from the ones the chief placed by hand — they are
-- otherwise identical — hence this column. It is the whole point: without it,
-- "clear the last prefill" and "delete the chief's work" are the same statement.
--
-- savePlanCell() deletes and re-inserts a cell without setting source, so opening a
-- prefilled cell and saving it hands ownership to the chief and the prefill stops
-- touching it. That is deliberate, not a leak.

alter table rota_plan
  add column if not exists source text;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'rota_plan_source_ck') then
    alter table rota_plan
      add constraint rota_plan_source_ck
      check (source is null or source = 'prefill');
  end if;
end $$;

-- The delete on a re-run is keyed on exactly these three columns.
create index if not exists rota_plan_source_ix
  on rota_plan (academic_year, source, block_number)
  where source is not null;

comment on column rota_plan.source is
  'prefill = written by the rota builder bulk prefill and replaced wholesale on the next run. null = placed or edited by hand and never touched by the prefill.';


-- ─── Verify ─────────────────────────────────────────────────────────────────
-- Every existing row predates the column, so all of them read as hand-placed.
-- That is the safe default: the first re-run after this migration will not delete
-- anything, it will only add.

select coalesce(source,'(hand-placed)') as source, count(*)
from rota_plan group by 1 order by 2 desc;
