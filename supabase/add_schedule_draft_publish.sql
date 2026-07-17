-- Draft/Publish workflow for Morning Meeting & Teaching schedules.
-- New sessions default to draft (published=false) and are only visible to
-- PD/chief and holders of edit_mm_schedule / edit_teach_schedule until an
-- editor explicitly publishes the block. Run this whole file in the
-- Supabase SQL Editor (Dashboard > SQL Editor > New query > paste > Run).

alter table mm_sessions add column if not exists published boolean not null default false;
alter table teaching_sessions add column if not exists published boolean not null default false;

drop policy if exists mm_sessions_select on mm_sessions;
create policy mm_sessions_select on mm_sessions for select to authenticated
  using (published or is_pd_or_chief() or has_priv('edit_mm_schedule'));

drop policy if exists teaching_sessions_select on teaching_sessions;
create policy teaching_sessions_select on teaching_sessions for select to authenticated
  using (published or is_pd_or_chief() or has_priv('edit_teach_schedule'));

-- Existing sessions were all effectively "live" to everyone before this
-- feature existed, so mark them published to avoid hiding anything that
-- residents could already see.
update mm_sessions set published=true where published=false;
update teaching_sessions set published=true where published=false;
