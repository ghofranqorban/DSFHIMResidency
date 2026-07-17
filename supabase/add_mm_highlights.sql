-- DSFH Residency Portal — add_mm_highlights.sql
-- Lets whoever can edit the Morning Meeting schedule (PD/deputy_pd/chief,
-- or anyone granted the 'edit_mm_schedule' privilege) add new custom
-- row-highlight colors from the schedule form, instead of being limited
-- to the fixed hardcoded list.
-- Run once in the Supabase SQL editor. Safe to re-run.

create table if not exists public.mm_highlights (
  id bigint generated always as identity primary key,
  label text not null,
  color text not null,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

alter table public.mm_highlights enable row level security;

create policy mm_highlights_select on public.mm_highlights for select to authenticated using (true);

create policy mm_highlights_write on public.mm_highlights for all to authenticated
  using (is_pd_or_chief() or has_priv('edit_mm_schedule'))
  with check (is_pd_or_chief() or has_priv('edit_mm_schedule'));
