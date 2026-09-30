-- The line the home page shows in front of the announcement time, written by
-- the PD on the Best Resident page ("Announced at the departmental meeting"
-- is only the stand-in when nothing has been written). Safe to re-run.
alter table public.best_resident_winners add column if not exists announcement_note text;

select column_name, data_type
from information_schema.columns
where table_schema = 'public' and table_name = 'best_resident_winners'
order by ordinal_position;
