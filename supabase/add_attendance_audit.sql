-- Attendance audit trail.
-- Run in the Supabase SQL editor. Idempotent: safe to run twice.
--
-- Every change to mm_attendance and teaching_attendance is recorded by a trigger inside the
-- database, so it is caught whichever screen, button or tool made the change. Recorded: who
-- (auth.uid()), when, the old and new status and comment, and the session date.
--
--   * INSERT  first time a resident is marked for a session
--   * UPDATE  only when the status or the comment actually changed. The "save whole session" buttons
--             re-send every row; re-saving an unchanged row writes nothing.
--   * DELETE  a mark removed (including when its session is deleted); changed_by may be empty then
--
-- Visible to role 'pd' only (the Program Director's own account): not deputy_pd, chief, dio or ceo.
-- Nobody can edit or delete a row through the API: there is no write rule, and the triggers write
-- as the table owner. Rows made from the SQL editor have an empty changed_by.

create table if not exists public.attendance_audit (
  id           bigint generated always as identity primary key,
  changed_at   timestamptz not null default now(),
  changed_by   uuid,
  kind         text not null check (kind in ('morning_meeting', 'academic_day')),
  op           text not null check (op in ('INSERT', 'UPDATE', 'DELETE')),
  session_id   bigint,
  session_date date,
  resident_id  bigint,
  old_status   text,
  new_status   text,
  old_comment  text,
  new_comment  text
);

create index if not exists attendance_audit_changed_at_idx on public.attendance_audit (changed_at desc);
create index if not exists attendance_audit_changed_by_idx on public.attendance_audit (changed_by);
create index if not exists attendance_audit_resident_idx   on public.attendance_audit (resident_id);

alter table public.attendance_audit enable row level security;

drop policy if exists attendance_audit_pd_read on public.attendance_audit;
create policy attendance_audit_pd_read on public.attendance_audit
  for select to authenticated
  using (coalesce(app_role() = 'pd', false));

-- No insert, update or delete rule exists for the API roles.
revoke all on public.attendance_audit from anon, authenticated;
grant select on public.attendance_audit to authenticated;

create or replace function public.attendance_audit_fn()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  k      text := case tg_table_name when 'mm_attendance' then 'morning_meeting' else 'academic_day' end;
  sid    bigint;
  rid    bigint;
  sd     date;
  o_st   text;  n_st  text;
  o_cm   text;  n_cm  text;
begin
  -- A failure to LOG must never stop attendance being saved, so the whole body is guarded.
  begin
    if tg_op = 'INSERT' then
      sid := new.session_id;  rid := new.resident_id;
      n_st := new.status;     n_cm := new.comment;
    elsif tg_op = 'UPDATE' then
      if old.status is not distinct from new.status
         and old.comment is not distinct from new.comment then
        return new;                     -- nothing a person would call a change
      end if;
      sid := new.session_id;  rid := new.resident_id;
      o_st := old.status;     n_st := new.status;
      o_cm := old.comment;    n_cm := new.comment;
    else
      sid := old.session_id;  rid := old.resident_id;
      o_st := old.status;     o_cm := old.comment;
    end if;

    if k = 'morning_meeting' then
      select s.session_date into sd from public.mm_sessions s where s.id = sid;
    else
      select s.session_date into sd from public.teaching_sessions s where s.id = sid;
    end if;

    insert into public.attendance_audit
      (changed_by, kind, op, session_id, session_date, resident_id, old_status, new_status, old_comment, new_comment)
    values
      (auth.uid(), k, tg_op, sid, sd, rid, o_st, n_st, o_cm, n_cm);
  exception when others then
    raise warning 'attendance_audit_fn could not log a change: %', sqlerrm;
  end;

  if tg_op = 'DELETE' then return old; end if;
  return new;
end $$;

revoke all on function public.attendance_audit_fn() from public;

drop trigger if exists mm_attendance_audit on public.mm_attendance;
create trigger mm_attendance_audit
  after insert or update or delete on public.mm_attendance
  for each row execute function public.attendance_audit_fn();

drop trigger if exists teaching_attendance_audit on public.teaching_attendance;
create trigger teaching_attendance_audit
  after insert or update or delete on public.teaching_attendance
  for each row execute function public.attendance_audit_fn();

-- ── Check what you got ──────────────────────────────────────────────────────
-- Expect: one SELECT-only rule named attendance_audit_pd_read, and two triggers.
select policyname, cmd, qual from pg_policies
 where schemaname = 'public' and tablename = 'attendance_audit';
select event_object_table as on_table, trigger_name, string_agg(event_manipulation, ', ' order by event_manipulation) as fires_on
  from information_schema.triggers
 where trigger_schema = 'public' and trigger_name in ('mm_attendance_audit', 'teaching_attendance_audit')
 group by 1, 2;

-- ── Reading it (run as the PD in the SQL editor, or through the portal later) ──────────────────
-- The editor runs as the owner, so it sees every row regardless of the rule above.
-- select a.changed_at, p.display_name as changed_by, p.role, a.kind, a.op, a.session_date,
--        r.name as resident, a.old_status, a.new_status, a.old_comment, a.new_comment
--   from attendance_audit a
--   left join profiles p on p.id = a.changed_by
--   left join residents r on r.id = a.resident_id
--  order by a.changed_at desc limit 200;
