-- CTU day cover is the 08:00-16:00 cover on Fri/Sat, not weekend on-call. The portal now counts it on
-- its own line and calls it "CTU Daycover". The column label is data (oncall_slots), so the rename
-- has to be run here; the code only carries the pre-migration fallback.
-- Idempotent: once no label contains "CTU Cover" it changes nothing.
update public.oncall_slots
   set label = replace(label, 'CTU Cover', 'CTU Daycover')
 where hours_mode = 'day'
   and label like '%CTU Cover%';

select slot_key, label, group_key, slot_index, hours_mode, days_mode from public.oncall_slots order by sort_order;
