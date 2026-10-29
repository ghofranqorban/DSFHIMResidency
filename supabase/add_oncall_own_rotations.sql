-- ============================================================================
-- Rotations that carry their own on-call.
--
-- A resident on Night Duty, Cardiology, ICU, Emergency Medicine or an
-- Elective takes their on-call inside that rotation, so for the block they
-- are outside the general on-call pool. The on-call builder reads this flag
-- to show who is actually available for a block, to sort the cell picker and
-- to mark an assignment that goes against the rota.
--
-- The flag is edited in Control Centre > Lists > Rotations ("Own on-call").
-- Until this column exists the portal uses the built-in set named above.
--
-- Run in the Supabase SQL Editor. Safe to re-run.
-- ============================================================================

alter table public.rotation_catalogue
  add column if not exists own_oncall boolean not null default false;

update public.rotation_catalogue
   set own_oncall = true
 where name in ('Night Duty','Cardiology','ICU','Emergency Medicine','Elective');

-- ── Check ───────────────────────────────────────────────────────────────────
select name, own_oncall, active
from public.rotation_catalogue
order by own_oncall desc, sort_order;
