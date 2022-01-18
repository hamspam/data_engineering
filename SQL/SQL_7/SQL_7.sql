-- person: 생성 
CREATE TABLE walker103.person (
	person_id int8 NOT NULL,
	year_of_birth int4 NOT NULL,
	month_of_birth int4 NULL,
	day_of_birth int4 NULL,
	death_date timestamp NULL,
	gender_value varchar(50) NULL,
	race_value varchar(50) NULL,
	ethnicity_value varchar(50) NULL,
	CONSTRAINT xpk_person PRIMARY KEY (person_id)
);

-- person: 추출/입력 
INSERT INTO walker103.person 
WITH tmp as (
	SELECT split_part(note, 'CONTINUING', 1) as data
	FROM clinical_note
)
SELECT 
   DISTINCT (SELECT coalesce(max(person_id), 0) + 1 as person_id FROM walker103.person),
   cast (substring(trim(split_part(data, 'Birth Date:', 2)),1 ,4) as integer) as year_of_birth,
   cast (substring(trim(split_part(data, 'Birth Date:', 2)),6 ,2) as integer) as month_of_birth,
   cast (substring(trim(split_part(data, 'Birth Date:', 2)),9 ,2) as integer) as day_of_birth,
   cast (null as timestamp) death_date,
   substring(trim(split_part(data, 'Gender:', 2)), 1, position(chr(10) in trim(split_part(data, 'Gender:', 2))) - 1) as gender_value,
   substring(trim(split_part(data, 'Race:', 2)), 1, position(chr(10) in trim(split_part(data, 'Race:', 2))) - 1) as race_value, 
   substring(trim(split_part(data, 'Ethnicity:', 2)), 1, position(chr(10) in trim(split_part(data, 'Ethnicity:', 2))) - 1) as ethnicity_value
FROM tmp
;


-- visit_occurrence: 생성 
CREATE TABLE walker103.visit_occurrence (
	visit_occurrence_id int8 NOT NULL,
	person_id int8 NOT NULL,
	visit_start_date date NULL,
	care_site_nm text NULL,
	visit_type_value varchar(50) NULL,
	CONSTRAINT xpk_visit_occurrence PRIMARY KEY (visit_occurrence_id),
	CONSTRAINT fpk_person FOREIGN KEY (person_id) REFERENCES walker103.person(person_id)
);

-- visit_occurrence: 추출/입력 
INSERT INTO walker103.visit_occurrence
WITH tmp as (
	SELECT 
	trim(replace(replace(split_part(split_part(note, 'CONTINUING', 1), 'ENCOUNTER', 2), chr(10), ''), chr(13), '')) as data
	FROM clinical_note
)
SELECT 
    row_number() over(ORDER BY substring(data, 1, 10)) visit_occurrence_id,
    (SELECT person_id FROM walker103.person) person_id,
    cast (substring(data, 1, 10) as date) visit_start_date,
	trim(split_part(split_part(split_part(data, 'Encounter at', 2), 'Type:', 1), ':', 1)) care_site_nm,
	trim(split_part(split_part(data, 'Type:', 2), 'MEDICATIONS:', 1)) visit_type_value
FROM tmp a
;


-- drug_exposure: 생성 
CREATE TABLE walker103.drug_exposure (
	drug_exposure_id int8 NOT NULL,
	person_id int8 NOT NULL,
	drug_exposure_start_date date NOT NULL,
	drug_value text NULL,
	route_value varchar(50) NULL,
	dose_value varchar(50) NULL,
	unit_value varchar(50) NULL,
	visit_occurrence_id int8 NULL,
	CONSTRAINT xpk_drug_exposure PRIMARY KEY (drug_exposure_id),
	CONSTRAINT fpk_drug_person FOREIGN KEY (person_id) REFERENCES walker103.person(person_id),
	CONSTRAINT fpk_drug_visit FOREIGN KEY (visit_occurrence_id) REFERENCES walker103.visit_occurrence(visit_occurrence_id)
);

-- drug_exposure: 추출/입력 
INSERT INTO walker103.drug_exposure
WITH tmp as (
	SELECT 
	trim(replace(replace(split_part(split_part(split_part(note, 'CONTINUING', 1), 'MEDICATIONS:', 2), 'CONDITIONS:', 1), chr(10), ''), chr(13), '')) as data
	FROM clinical_note
)
SELECT 
    row_number() over(ORDER BY substring(data, 1, 10)) drug_exposure_id,
	(SELECT person_id FROM walker103.person) person_id,
	cast (substring(data, 1, 10) as date) drug_exposure_start_date,
    regexp_match(split_part(data, ' : ', 2), '[^0-9]+') drug_value,
    split_part(trim(regexp_replace(regexp_replace(split_part(data, ' : ', 2), '[^0-9]+', ''), '[0-9]+', '')), ' ', 2) route_value,
	regexp_match(split_part(data, ' : ', 2), '[0-9]+') dose_value,
	split_part(trim(regexp_replace(regexp_replace(split_part(data, ' : ', 2), '[^0-9]+', ''), '[0-9]+', '')), ' ', 1) unit_value,
	(
	 SELECT max(b.visit_occurrence_id) 
	 FROM walker103.visit_occurrence b 
	 WHERE cast (substring(a.data, 1, 10) as date) = b.visit_start_date
	) as visit_occurrence_id
FROM tmp a 
WHERE substring(data, 1, 10) <> ''
;


-- condition_occurrence: 생성 
CREATE TABLE walker103.condition_occurrence (
	condition_occurrence_id int8 NOT NULL,
	person_id int8 NOT NULL,
	condition_start_date date NOT NULL,
	condition_value text NULL,
	visit_occurrence_id int8 NULL,
	CONSTRAINT xpk_condition_occurrence PRIMARY KEY (condition_occurrence_id),
	CONSTRAINT fpk_condition_person FOREIGN KEY (person_id) REFERENCES walker103.person(person_id),
	CONSTRAINT fpk_condition_visit FOREIGN KEY (visit_occurrence_id) REFERENCES walker103.visit_occurrence(visit_occurrence_id)
);

-- condition_occurrence: 추출/입력 
INSERT INTO walker103.condition_occurrence
WITH tmp as (
	SELECT 
	trim(replace(replace(split_part(split_part(split_part(note, 'CONTINUING', 1), 'CONDITIONS:', 2), 'CARE PLANS:', 1), chr(10), ''), chr(13), '')) as data
	FROM clinical_note
)
SELECT row_number() over(ORDER BY substring(data, 1, 10)) condition_occurrence_id,
    (SELECT person_id FROM walker103.person) person_id,
	cast (substring(data, 1, 10) as date) condition_start_date,
	trim(split_part(data, ' : ', 2))condition_value,
	(
	 SELECT max(b.visit_occurrence_id) 
	 FROM walker103.visit_occurrence b 
	 WHERE cast (substring(a.data, 1, 10) as date) = b.visit_start_date
	) as visit_occurrence_id
FROM tmp a 
WHERE substring(data, 1, 10) <> ''
ORDER BY substring(data, 1, 10)
;

   
