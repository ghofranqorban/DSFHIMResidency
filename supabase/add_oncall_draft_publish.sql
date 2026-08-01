-- Draft/Publish workflow for the On-Call schedule, matching the pattern
-- used for Morning Meeting & Teaching schedules (add_schedule_draft_publish.sql).
-- New rows default to draft (published=false) and are only visible to
-- PD/chief and holders of edit_oncall until an editor explicitly publishes
-- the block. Run this whole file in the Supabase SQL Editor
-- (Dashboard > SQL Editor > New query > paste > Run).

alter table oncall_schedule add column if not exists published boolean not null default false;

drop policy if exists "authenticated can read oncall_schedule" on oncall_schedule;
drop policy if exists oncall_schedule_select on oncall_schedule;
create policy oncall_schedule_select on oncall_schedule for select to authenticated
  using (published or is_pd_or_chief() or has_priv('edit_oncall'));

-- Existing rows were all effectively "live" to everyone before this
-- feature existed, so mark them published to avoid hiding anything that
-- residents could already see.
update oncall_schedule set published=true where published=false;
