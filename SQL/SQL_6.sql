/*
 * drug_concept_id: '19018935','1539411','1539463','19075601','1115171
 * 위 조건의 데이터 추출 후,
 * 패턴과 해당 환자 수를 찾은 다음에 union 해 보는 방향으로 생각해 봤습니다. 
 */

with tmp as (
select row_number() over(partition by co.person_id order by ex.drug_exposure_start_date, ex.drug_concept_id)
, ex.drug_concept_id, co.visit_occurrence_id, *
from de.condition_occurrence co
    join de.drug_exposure ex
    on co.person_id = ex.person_id 
    and co.visit_occurrence_id = ex.visit_occurrence_id
    and ex.drug_concept_id in ('19018935','1539411','1539463','19075601','1115171')
where co.person_id =347825
)
select 'a -> (b,c)' pattern, '' person_count
from tmp
union
select 'a -> b -> c' pattern, '' person_count
from tmp
;
