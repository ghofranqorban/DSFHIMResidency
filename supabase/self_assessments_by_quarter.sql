-- DSFH Residency Portal — self-assessment by quarter (the PD, 29 Oct 2026: "make self by quarter as the
-- learning plan by mentor"). self_assessments.period and self_assessment_periods.period become the quarter
-- (1 = Oct–Dec, 2 = Jan–Mar, 3 = Apr–Jun, 4 = Jul–Sep), the same as mentorship_evaluations.quarter. The two
-- rows saved as "Apr–Sep 2026" (academic_year 2025, period 2) become Q4 of 2025-26. A resident may write a
-- quarter from the first day of its last month (1 Dec, 1 Mar, 1 Jun, 1 Sep), as for the learning plan.
-- Run once in the Supabase SQL Editor, after add_self_assessments.sql.

alter table self_assessments drop constraint if exists self_assessments_period_check;
alter table self_assessments add constraint self_assessments_period_check check (period between 1 and 4);
alter table self_assessment_periods drop constraint if exists self_assessment_periods_period_check;
alter table self_assessment_periods add constraint self_assessment_periods_period_check check (period between 1 and 4);

update self_assessments s set period = 4, updated_at = now()
 where s.academic_year = 2025 and s.period = 2
   and not exists (select 1 from self_assessments x where x.resident_id = s.resident_id and x.academic_year = 2025 and x.period = 4);
update self_assessment_periods set period = 4, label = 'Q4', updated_at = now() where academic_year = 2025 and period = 2;

drop policy if exists self_assessments_write on self_assessments;
create policy self_assessments_write on self_assessments for all to authenticated using (
  app_role() = 'resident' and resident_id = app_resident_id()
  and current_date >= make_date(case when period = 1 then academic_year else academic_year + 1 end, (array[12,3,6,9])[period], 1)
  and not exists (select 1 from self_assessment_periods p
                  where p.academic_year = self_assessments.academic_year and p.period = self_assessments.period and p.locked)
) with check (
  app_role() = 'resident' and resident_id = app_resident_id()
  and current_date >= make_date(case when period = 1 then academic_year else academic_year + 1 end, (array[12,3,6,9])[period], 1)
  and not exists (select 1 from self_assessment_periods p
                  where p.academic_year = self_assessments.academic_year and p.period = self_assessments.period and p.locked)
);

-- Expected: both rows now academic_year 2025, period 4.
select id, resident_id, academic_year, period, status from self_assessments order by id;
