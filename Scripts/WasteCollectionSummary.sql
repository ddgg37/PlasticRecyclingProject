
CREATE TABLE waste_collection_summary (
waste_processor_id INT,
authority VARCHAR(255), 
authority_id INT,
period VARCHAR(20),
period_id INT,
waste_stream_type_id INT,
waste_stream_type VARCHAR(80),
facility_type_id INT,
facility_type VARCHAR(80),
national_facility_id INT,
facility_name VARCHAR(80),
facility_postCode VARCHAR(10),
total_tonnes FLOAT,
tonnes_by_material FLOAT,
material_group VARCHAR(80),
material_id INT,
material VARCHAR(50),
tonnes_material FLOAT,
population_percentage FLOAT
);

INSERT INTO waste_collection_summary
SELECT 
	waste_processor_id,
	authority, 
	authority_id,
	period,
	period_id,
	waste_stream_type_id,
	waste_stream_type,
	facility_type_id,
	facility_type,
	national_facility_id,
	facility_name,
	facility_postCode,
	total_tonnes,
    tonnes_by_material,
	material_group,
	material_id,
	material
FROM dataschool_project.waste_collection
where national_facility_id != 0;

-- We store this variable to usie it inm next query 
SELECT population 
INTO @England_population
FROM authority_locations_lookup 
WHERE location_name = 'ENGLAND';

UPDATE waste_collection_summary wc
JOIN dataschool_project.authority_locations_lookup al
ON wc.authority_id = al.authority_id 
SET wc.tonnes_material = ROUND(SUM(wc.tonnes_by_material), 2),
	wc.population_percentage = ROUND((al.population * 100)/@England_population, 2);

-- ###################################################################

SELECT distinct(authority)  
FROM dataschool_project.waste_collection_summary;

-- Data Analisys
SELECT DISTINCT(material),material_group,authority, period_id, period, tonnes_by_material, total_tonnes 
FROM dataschool_project.waste_collection_summary
WHERE TRIM(material) != '';

SELECT * FROM dataschool_project.waste_collection_summary 
WHERE TRIM(material) = ''; -- check waste stream type

-- General information
SELECT wc.material,wc.authority, wc.period_id, wc.period, SUM(wc.tonnes_by_material), al.population
FROM dataschool_project.waste_collection_summary wc
JOIN dataschool_project.authority_locations_lookup al
ON wc.authority_id = al.authority_id
WHERE TRIM(wc.material) != ''
GROUP BY wc.material,wc.authority, wc.period_id, wc.period, al.population;

SELECT wc.authority_id, wc.authority, wc.total_tonnes 
FROM dataschool_project.waste_collection_summary wc
JOIN dataschool_project.authority_locations_lookup al
ON wc.authority = al.authority_name;


-- SUM of tonnes by material
SELECT 
	wc.material,
    al.authority_convert, 
    al.population, 
    wc.period, 
    ROUND(SUM(wc.tonnes_by_material), 2) as material_tonnes, 
    ROUND((al.population * 100)/@England_population, 2) as population_percentage
FROM dataschool_project.waste_collection_summary wc
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
FROM dataschool_project.waste_collection_summary
WHERE material LIKE CONCAT('%', @character13, '%') OR 
	material LIKE CONCAT('%', @character10, '%') OR 
	material LIKE CONCAT('%', @character9, '%'); 
    
    


