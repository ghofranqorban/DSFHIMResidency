-- Fix: KPI evidence file uploads fail with
-- "Upload failed: new row violates row-level security policy"
-- Root cause: the kpi-evidence Storage bucket was created private (10 Jul 2026)
-- but no RLS policies were ever added on storage.objects for it. Only the
-- service_role key bypasses RLS, so every real resident/mentor/chief/PD
-- session fails to upload or read files (not user-specific — affects everyone).
-- Run in: Supabase > SQL Editor > New query. Safe to re-run (drops first).

drop policy if exists "kpi_evidence_insert_authenticated" on storage.objects;
drop policy if exists "kpi_evidence_select_authenticated" on storage.objects;
drop policy if exists "kpi_evidence_update_authenticated" on storage.objects;

create policy "kpi_evidence_insert_authenticated"
on storage.objects for insert
to authenticated
with check (bucket_id = 'kpi-evidence');

create policy "kpi_evidence_select_authenticated"
on storage.objects for select
to authenticated
using (bucket_id = 'kpi-evidence');

create policy "kpi_evidence_update_authenticated"
on storage.objects for update
to authenticated
using (bucket_id = 'kpi-evidence')
with check (bucket_id = 'kpi-evidence');

-- Verify: log in as any non-PD resident, go to KPI > Yearly, submit an
-- achievement with a PDF/file attached — should succeed. PD should also
-- be able to view/download the attached evidence from the review panel.
