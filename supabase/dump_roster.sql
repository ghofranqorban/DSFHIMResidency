-- Current roster with the rota years each resident already has.
-- Needed to widen the historical import beyond the R4s: the workbook spells names
-- differently every year, so each one has to be mapped to a username by hand.

select res.id, res.username, res.name, res.level,
       coalesce(string_agg(distinct r.academic_year::text, ', '
                           order by r.academic_year::text), 'none') as years_in_db
from residents res
left join rotations r on r.resident_id = res.id
group by res.id, res.username, res.name, res.level
order by res.level, res.name;
