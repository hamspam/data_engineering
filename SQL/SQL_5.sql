/*
 * a. condition_concept_id: 3191208,36684827,3194332,3193274,43531010,4130162,45766052, 45757474,4099651,4129519,4063043,4230254,4193704,4304377,20 1826,3194082,3192767
   b. 18세 이상의 환자
   c. drug_concept_id: 40163924 => 90일 이상 복용
 해당 조건에 맞게 데이터 추출
 */
SELECT count(1)
FROM de.condition_occurrence co
    JOIN de.person p
    ON co.person_id = p.person_id
    JOIN de.drug_exposure c
    ON co.person_id = c.person_id
    AND co.visit_occurrence_id = c.visit_occurrence_id
WHERE co.condition_concept_id IN ('3191208','36684827','3194332','3193274','43531010','4130162','45766052', '45757474','4099651','4129519','4063043','4230254','4193704','4304377','201826','3194082','3192767')
AND extract (YEAR FROM age(p.birth_datetime)) >= 18
AND c.drug_concept_id  = 40163924
AND c.drug_exposure_end_date - c.drug_exposure_start_date >= 90
;