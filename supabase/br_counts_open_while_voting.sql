-- Best Resident: let everyone see the live standings while voting is open.
--
-- Until now, once a quarter had ended best_resident_tally() withheld every candidate's vote count
-- from everyone but the PD and deputy until the announcement (br_public false). The PD wants
-- residents to follow the standings while votes come in, so br_public is also true while voting is
-- open. When voting closes (voting_open off, or the deadline passes) the counts are withheld again
-- until the announcement, so the final result is still a reveal.
--
-- br_voting_open() comes from add_best_resident_sealing.sql. Idempotent.
-- To go back to the sealed behaviour, run the original br_public from that file.
create or replace function br_public(ay int, q int)
returns boolean
language sql stable security definer set search_path = public
as $$
  select now() < br_quarter_end(ay, q)
      or br_voting_open(ay, q)
      or exists (select 1 from best_resident_winners w
                  where w.academic_year = ay and w.quarter = q
                    and coalesce(w.announced, false)
                    and (w.announced_at is null or w.announced_at <= now()));
$$;

-- Check: br_voting_open and br_public for the quarter being voted on now. With voting open, both
-- are true; with voting closed and nothing announced, both are false.
select br_voting_open(2025, 4) as voting_open, br_public(2025, 4) as counts_public;
