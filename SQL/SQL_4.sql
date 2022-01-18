/*
 * 두번째 약의 처방 건수가 첫번째 약의 처방 건수보다 더 많은 첫번째 약의 약품명을 처방건수 순으로 출력
 * 첫번째 약의 처방건수를 오름차순으로 정렬
 */
WITH drug_list AS (
	SELECT distinct drug_concept_id, concept_name, count(*) AS cnt 
	FROM de.drug_exposure de
	    JOIN de.concept
	    ON drug_concept_id = concept_id
	WHERE concept_id IN ( 40213154,19078106,19009384,40224172,19127663,1511248,40169216,1539463, 19126352,1539411,1332419,40163924,19030765,19106768,19075601)
	GROUP BY drug_concept_id,concept_name
	ORDER BY count(*) DESC
	)
, drugs as (SELECT drug_concept_id, concept_name FROM drug_list)
, prescription_count AS (SELECT drug_concept_id, cnt FROM drug_list)
SELECT a.concept_name
FROM drugs a
    JOIN prescription_count b
    ON a.drug_concept_id = b.drug_concept_id
    JOIN drug_pair c
    ON a.drug_concept_id = c.drug_concept_id1
    JOIN prescription_count d
    ON d.drug_concept_id = c.drug_concept_id2
 WHERE b.cnt < d.cnt
 ORDER BY b.cnt
 ;