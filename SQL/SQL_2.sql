/*
 * 첫글자: (a,b,c,d,e) 문자로 시작
 * 중간에 “heart” 단어가 포함된 상병 이름 추출
 * 1) 대소문자를 구분하지 않음 => lower 처리
 * 2) 상병 이름을 중복없이 나열 => distinct 처리
 */
SELECT DISTINCT c.concept_name
FROM de.condition_occurrence co
    INNER JOIN de.concept c
    ON co.condition_concept_id  = c.concept_id
WHERE c.concept_name LIKE '_%heart%'
AND lower(c.concept_name) SIMILAR TO '(a|b|c|d|e)%'
ORDER BY c.concept_name
;