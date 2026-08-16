-- Add split-block support to `rotations`, then widen the unique key to include it.
--
-- A block is 4 weeks. Two things can split it:
--   * 2 weeks of leave alongside a rotation -> leave_weeks/leave_position (already existed)
--   * two genuine rotations, 2 weeks each   -> a second row with segment = 2
--
-- `weeks` records how long the rotation in THIS row actually ran, so cumulative
-- training time can be summed without re-deriving it from the split flags.
--
-- Safe to run more than once.

begin;

alter table rotations add column if not exists segment int not null default 1;
alter table rotations add column if not exists weeks   int not null default 4;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conrelid = 'rotations'::regclass and conname = 'rotations_segment_check'
  ) then
    alter table rotations add constraint rotations_segment_check check (segment between 1 and 2);
  end if;

  if not exists (
    select 1 from pg_constraint
    where conrelid = 'rotations'::regclass and conname = 'rotations_weeks_check'
  ) then
    alter table rotations add constraint rotations_weeks_check check (weeks between 1 and 4);
  end if;
end $$;

-- Drop the old 3-column unique key. Its generated name is not guaranteed, so find
-- it by its exact column set rather than hardcoding a name.
do $$
declare
  cname text;
begin
  select con.conname into cname
  from pg_constraint con
  where con.conrelid = 'rotations'::regclass
    and con.contype = 'u'
    and (
      select array_agg(att.attname::text order by att.attname)
      from unnest(con.conkey) k
      join pg_attribute att on att.attrelid = con.conrelid and att.attnum = k
    ) = array['academic_year','block_number','resident_id'];

  if cname is not null then
    execute format('alter table rotations drop constraint %I', cname);
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conrelid = 'rotations'::regclass and conname = 'rotations_block_segment_key'
  ) then
    alter table rotations
      add constraint rotations_block_segment_key
      unique (resident_id, academic_year, block_number, segment);
  end if;
end $$;

-- Historical years are read-only in the portal, but RLS still has to let them be read.
create index if not exists rotations_resident_year_idx
  on rotations (resident_id, academic_year);

commit;

-- Verify:
--   select conname, pg_get_constraintdef(oid) from pg_constraint
--   where conrelid = 'rotations'::regclass and contype = 'u';
-- Expect exactly one unique constraint, over the four columns.
