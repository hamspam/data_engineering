/*
 * 환자번호 ‘1891866’ 환자의 약 처방 데이터에서
 * 처방된 약의 종류별로 처음 시작일, 마지막 종료일, 복용일(마지막 종료일과 처음시작일의 차이)을 구하고,
 * 복용일이 긴 순으로 정렬하여 테이블을 생성
 * walker103 스키마 밑에 drug_exposure_result 테이블 생성 처리
 */ 
CREATE TABLE walker103.drug_exposure_result AS (
	SELECT drug_concept_id, 
	       min(drug_exposure_start_date) 처음_시작일,
	       max(drug_exposure_end_date) 마지막_종료일,
	       max(drug_exposure_end_date) - min(drug_exposure_start_date) 복용일
	FROM de.drug_exposure
	WHERE person_id = 1891866
	GROUP BY drug_concept_id
	ORDER BY 4 DESC
)
;

-- drug_exposure_result 조회
SELECT * 
FROM walker103.drug_exposure_result
;