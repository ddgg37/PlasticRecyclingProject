
-- ################################### Adapt location name to LAD table ###############################################

-- Export England Data from table
/*SELECT
	'location_code',
	'location_name',
	'geography_type',
	'population'
UNION ALL
SELECT
	location_code,
	location_name,
	geography_type,
	population
FROM dataschool_project.main_population_UK_by_location_2024
WHERE location_code LIKE 'E%' 
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ExportEnglandPopulationByAuthority2024.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';*/

-- #############################################################################

-- Cleanup all the records with geography_type NULL as they are Counties we are not interested on
#DELETE FROM dataschool_project.main_population_UK_by_location_2024 WHERE geography_type IS NULL;

SELECT count(distinct(pe.location_code)) FROM dataschool_project.main_population_UK_by_location_2024 pe; -- 357

SELECT pe.location_name FROM dataschool_project.main_population_UK_by_location_2024 pe
where location_name like '%lynn%';

#SELECT pe.location_name,  ld.lad25_name, ld.lad25_code
SELECT count(distinct(ld.lad25_code))
FROM dataschool_project.main_population_UK_by_location_2024 pe
JOIN dataschool_project.lad_dec_2025 ld
ON pe.location_name = ld.lad25_name; -- 317

SELECT *
FROM dataschool_project.main_population_UK_by_location_2024 pe
WHERE pe.location_name NOT IN (
	SELECT ld.lad25_name 
	FROM dataschool_project.lad_dec_2025 ld
);

SELECT distinct(geography_type) FROM dataschool_project.main_population_UK_by_location_2024;

SELECT count(distinct(location_name)) FROM dataschool_project.main_population_UK_by_location_2024
WHERE geography_type NOT IN ('Country', 'County', 'Region', 'Metropolitan County'); -- 318

-- Locations inside Population csv
Select *  
from dataschool_project.main_population_UK_by_location_2024
ORDER BY location_name;

-- All the locations but type: Region, Country, County, Metropolitan County 
Select geography_type, location_name, location_code
from dataschool_project.main_population_UK_by_location_2024
where geography_type NOT IN ('Region', 'Country', 'County', 'Metropolitan County');


-- char 13 is return character
SET @character13 = CHAR(13);
-- char 10 is line feed
SET @character10 = CHAR(10);
-- char 9 is tab
SET @characterTab = CHAR(9);

SELECT location_name, 
CASE
	WHEN location_name LIKE CONCAT('%', @character13, '%') THEN 'Return'
	WHEN location_name LIKE CONCAT('%', @character10, '%') THEN 'Line Feed'
	WHEN location_name LIKE CONCAT('%', @character9, '%') THEN 'Tab'
    WHEN location_name LIKE CONCAT('%', @character34, '%') THEN 'Double Quotes'
    ELSE 'Empty'
END  
FROM dataschool_project.main_population_UK_by_location_2024
WHERE location_name LIKE CONCAT('%', @character13, '%') OR 
	location_name LIKE CONCAT('%', @character10, '%') OR 
	location_name LIKE CONCAT('%', @character9, '%') OR 
    location_name LIKE CONCAT('%',  @character34, '%'); 

-- This query shows what character contains in MaterialGroup
SELECT geography_type, 
CASE
	WHEN geography_type LIKE CONCAT('%', @character13, '%') THEN 'Return'
	WHEN geography_type LIKE CONCAT('%', @character10, '%') THEN 'Line Feed'
	WHEN geography_type LIKE CONCAT('%', @character9, '%') THEN 'Tab'
    ELSE 'Empty'
END  
FROM dataschool_project.main_population_UK_by_location_2024
WHERE geography_type LIKE CONCAT('%', @character13, '%') OR 
	geography_type LIKE CONCAT('%', @character10, '%') OR 
	geography_type LIKE CONCAT('%', @character9, '%'); 

SELECT * 
FROM dataschool_project.main_population_UK_by_location_2024 pe 
WHERE pe.geography_type != 'Metropolitan County' AND pe.geography_type != 'Country' AND pe.geography_type != 'Region' AND pe.geography_type != 'County';

SELECT * 
FROM dataschool_project.main_population_UK_by_location_2024 pe
where location_name LIKE '%London%';

-- char 13 is return character
SET @character13 = CHAR(13);
-- char 10 is line feed
SET @character10 = CHAR(10);
-- char 9 is tab
SET @characterTab = CHAR(9);

-- This query shows what character contains in MaterialGroup
SELECT geography_type, 
CASE
	WHEN geography_type LIKE CONCAT('%', @character13, '%') THEN 'Return'
	WHEN geography_type LIKE CONCAT('%', @character10, '%') THEN 'Line Feed'
	WHEN geography_type LIKE CONCAT('%', @character9, '%') THEN 'Tab'
    ELSE 'Empty'
END  
FROM dataschool_project.main_population_UK_by_location_2024
WHERE geography_type LIKE CONCAT('%', @character13, '%') OR 
	geography_type LIKE CONCAT('%', @character10, '%') OR 
	geography_type LIKE CONCAT('%', @character9, '%'); 
    
    
-- We store this variable to usie it inm next query 
SELECT population 
INTO @England_population
FROM authority_locations_lookup 
WHERE location_name = 'ENGLAND';

SET @tones_material = 0;
SET @population_percentage = 0.00;

UPDATE waste_collection_2025_summary wc
JOIN dataschool_project.authority_locations_lookup al
ON wc.authority_id = al.authority_id 
SET tonnes_material = ROUND(SUM(wc.tonnes_by_material), 2),
 population_percentage = ROUND((al.population * 100)/@England_population, 2);
    
