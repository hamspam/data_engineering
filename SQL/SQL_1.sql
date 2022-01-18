--모든 환자에 대해 총 내원일수 구하기 
SELECT person_id, 
       sum(visit_end_date - visit_start_date + 1) AS da
FROM de.visit_occurrence
GROUP BY 1
ORDER BY 1
;

--총 내원일수의 최대값과 총 내원일수 최대값을 가지는 환자 수를 찾는 쿼리를 작성
WITH tmp AS (
	SELECT person_id, 
	       sum(visit_end_date - visit_start_date + 1) AS da
	FROM de.visit_occurrence
	GROUP by 1
)
SELECT da 총_내원일수_최대값, count(1) 환자_수
FROM tmp
GROUP BY 1
ORDER BY 1 DESC
LIMIT 1
;