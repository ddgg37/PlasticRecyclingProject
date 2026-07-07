
CREATE TABLE waste_collection_2025_summary (
waste_processor_id INT,
authority VARCHAR(255), 
authority_id INT,
period_id INT,
period_start DATE,
period_end DATE,
waste_stream_type_id INT,
waste_stream_type VARCHAR(80),
facility_type_id INT,
facility_type VARCHAR(80),
national_facility_id INT,
facility_name VARCHAR(80),
facility_postCode VARCHAR(10),
total_tonnes FLOAT,
material_group VARCHAR(80),
material_id INT,
material VARCHAR(50),
tonnes_by_material FLOAT
);

INSERT INTO waste_collection_2025_summary
SELECT 
	waste_processor_id,
	authority, 
	authority_id,
	period_id,
    STR_TO_DATE(CONCAT(TRIM(SUBSTRING_INDEX(period, ' - ', 1)), ' 01'), '%b %y %d'),
    STR_TO_DATE(CONCAT(TRIM(SUBSTRING_INDEX(period, ' - ', -1)), ' 01'), '%b %y %d'),
	waste_stream_type_id,
	waste_stream_type,
	facility_type_id,
	facility_type,
	national_facility_id,
	facility_name,
	facility_postCode,
	total_tonnes,
	material_group,
	material_id,
	material,
	tonnes_by_material
FROM dataschool_project.main_waste_collection_2025
where waste_processor_id != 0;

-- Clean up Authories
SELECT DISTINCT(RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Authority, 'Council', ''), 'Borough', ''), 'District',''), 'MBC',''), 'LB', ''), 'County', ''),'City',''),'Waste',''),'Authority',''),'WDA ()',''),'MDC ()',''),'MDC','')))) AS authority_converted 
FROM dataschool_project.waste_collection_2025_summary;

UPDATE dataschool_project.waste_collection_2025_summary
SET authority = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Authority, 'Council', ''), 'Borough', ''), 'District',''), 'MBC',''), 'LB', ''), 'County', ''),'City',''),'Waste',''),'Authority',''),'WDA ()',''),'MDC ()',''),'MDC','')));

-- char 13 is return character
SET @character13 = CHAR(13);
-- char 10 is line feed
SET @character10 = CHAR(10);
-- char 9 is tab
SET @character9 = CHAR(9);

-- This query shows what character contains in MaterialGroup
SELECT material_group, 
CASE
	WHEN material_group LIKE CONCAT('%', @character13, '%') THEN 'Return'
	WHEN material_group LIKE CONCAT('%', @character10, '%') THEN 'Line Feed'
	WHEN material_group LIKE CONCAT('%', @character9, '%') THEN 'Tab'
    ELSE 'Empty'
END  
FROM dataschool_project.waste_collection_2025_summary
WHERE material_group LIKE CONCAT('%', @character13, '%') OR 
	material_group LIKE CONCAT('%', @character10, '%') OR 
	material_group LIKE CONCAT('%', @character9, '%'); 

-- Remove Return, line feed or tab characters
UPDATE dataschool_project.waste_collection_2025_summary 
SET material_group = 
		REPLACE(
			REPLACE(
				REPLACE(material_group, @character13, ''),
			@character10, ''),
		@character9, '')
WHERE material_group LIKE CONCAT('%', @character13, '%')
   OR material_group LIKE CONCAT('%', @character10, '%')
   OR material_group LIKE CONCAT('%', @character9, '%');


-- ###################################################################

-- Export Data for Tableau
SELECT
	'waste_processor_id',
	'authority', 
	'authority_id',
	'period_id',
    'period_start',
	'period_end',
	'waste_stream_type_id',
	'waste_stream_type',
	'facility_type_id',
	'facility_type',
	'national_facility_id',
	'facility_name',
	'facility_postCode',
	'total_tonnes',
	'material_group',
	'material_id',
	'material',
	'tonnes_by_material'
UNION ALL
SELECT
	waste_processor_id,
	authority, 
	authority_id,
	period_id,
    period_start,
	period_end,
	waste_stream_type_id,
	waste_stream_type,
	facility_type_id,
	facility_type,
	national_facility_id,
	facility_name,
	facility_postCode,
	total_tonnes,
	material_group,
	material_id,
	material,
	tonnes_by_material    
FROM dataschool_project.waste_collection_2025_summary
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ExportFromDBWasteCollectionSummary.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- #####################################################################


SELECT distinct(authority)  
FROM dataschool_project.waste_collection_2025_summary;

-- Data Analisys
SELECT DISTINCT(material),material_group,authority, period_id, period, tonnes_by_material, total_tonnes 
FROM dataschool_project.waste_collection_2025_summary
WHERE TRIM(material) != '';

SELECT * FROM dataschool_project.waste_collection_2025_summary 
WHERE TRIM(material) = ''; -- check waste stream type

-- General information
SELECT wc.material,wc.authority, wc.period_id, wc.period, SUM(wc.tonnes_by_material), al.population
FROM dataschool_project.waste_collection_2025_summary wc
JOIN dataschool_project.authority_locations_lookup al
ON wc.authority_id = al.authority_id
WHERE TRIM(wc.material) != ''
GROUP BY wc.material,wc.authority, wc.period_id, wc.period, al.population;

SELECT wc.authority_id, wc.authority, wc.total_tonnes 
FROM dataschool_project.waste_collection_2025_summary wc
JOIN dataschool_project.authority_locations_lookup al
ON wc.authority = al.authority_name;

SELECT count(wc.authority_id) 
FROM dataschool_project.waste_collection_2025_summary wc
JOIN dataschool_project.authority_locations_lookup al
ON wc.authority_id = al.authority_id; -- 15069

SELECT count(wc.authority_id) 
FROM dataschool_project.waste_collection_2025_summary wc
JOIN dataschool_project.authority_locations_lookup al
ON wc.authority = al.authority_convert; -- 15069


-- SUM of tonnes by material
SELECT 
	wc.material,
    al.authority_convert, 
    al.population, 
    wc.period, 
    ROUND(SUM(wc.tonnes_by_material), 2) as material_tonnes, 
    ROUND((al.population * 100)/@England_population, 2) as population_percentage
FROM dataschool_project.waste_collection_2025_summary wc
JOIN dataschool_project.authority_locations_lookup al
ON wc.authority_id = al.authority_id
WHERE TRIM(wc.material) != ''
GROUP BY wc.material,al.authority_convert, al.population, wc.period
ORDER BY SUM(wc.tonnes_by_material) DESC;

-- char 13 is return character
SET @character13 = CHAR(13);
-- char 10 is line feed
SET @character10 = CHAR(10);
-- char 9 is tab
SET @characterTab = CHAR(9);

-- This query shows what character contains in MaterialGroup
SELECT material, 
CASE
	WHEN material LIKE CONCAT('%', @character13, '%') THEN 'Return'
	WHEN material LIKE CONCAT('%', @character10, '%') THEN 'Line Feed'
	WHEN material LIKE CONCAT('%', @character9, '%') THEN 'Tab'
    ELSE 'Empty'
END  
FROM dataschool_project.waste_collection_2025_summary
WHERE material LIKE CONCAT('%', @character13, '%') OR 
	material LIKE CONCAT('%', @character10, '%') OR 
	material LIKE CONCAT('%', @character9, '%'); 
    
SELECT count(distinct(wc.authority_id)) 
FROM dataschool_project.waste_collection_2025_summary wc
JOIN dataschool_project.authority_locations_lookup al
ON wc.authority_id = al.authority_id;  -- 321

SELECT count(*) 
FROM dataschool_project.authority_locations_lookup al
JOIN dataschool_project.local_authority_districts_2025 la
ON al.authority_convert = la.lad25_name
where la.lad25_code LIKE 'E%';  -- 292

SELECT authority, tonnes_by_material, total_tonnes FROM dataschool_project.main_waste_collection_2025;

-- total tonnes per period
SELECT SUM(total_tonnes), SUM(tonnes_by_material), period_id FROM dataschool_project.main_waste_collection_2025
GROUP BY total_tonnes, tonnes_by_material, period_id;

-- total tonnest per population and material
SELECT SUM(total_tonnes), SUM(tonnes_by_material), period_id FROM dataschool_project.main_waste_collection_2025
GROUP BY total_tonnes, tonnes_by_material, period_id;

-- total tonnest when tonnes per material is zero
SELECT * FROM dataschool_project.main_waste_collection_2025
where output_process_type = 'Treatment unknown';

-- to differetiate total_tonnes and tonnes by material
SELECT SUM(total_tonnes), SUM(tonnes_by_material), material, authority FROM dataschool_project.main_waste_collection_2025
GROUP BY total_tonnes, tonnes_by_material, material, authority;



