
SET GLOBAL local_infile = 1;

-- Create Table
CREATE TABLE dataschool_project.population_UK_by_location_2024 (
location_code VARCHAR(15),
location_name VARCHAR(100),
geography_type VARCHAR(100),
population INT);



-- Import Data from csv file in my local machine
LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProject/Datasets/OriginalResources/PopulationByAuthority2024.csv'
INTO TABLE dataschool_project.population_UK_by_location_2024
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ################################### Adapt location name to LAD table ###############################################

-- we update location_name converted from population_england
SELECT LTRIM(RTRIM(
	REGEXP_REPLACE(		
		REGEXP_REPLACE(		
			REGEXP_REPLACE(		
				REGEXP_REPLACE(
					location_name,
					'\\s*[-.]\\s*',
					' '
				),
				', City of',
				''
			),
			', County of',
			''
		),
		"'",
		''
	)
)) as converted
FROM dataschool_project.population_UK_by_location_2024 
where location_name LIKE '%lynn%';

UPDATE dataschool_project.population_UK_by_location_2024 
SET location_name = LTRIM(RTRIM(		
	REGEXP_REPLACE(
		REGEXP_REPLACE(
			REGEXP_REPLACE(
				REGEXP_REPLACE(
					location_name,
					'\\s*[-.]\\s*',
					' '
				),
				', City of',
				''
			),
			', County of',
			''
		),
		"'",
		''
	)
));

-- #############################################################################

-- Export England Data from table
SELECT
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
FROM dataschool_project.population_UK_by_location_2024
WHERE location_code LIKE 'E%' 
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ExportEnglandPopulationByAuthority2024.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- #############################################################################

SELECT count(distinct(pe.location_code)) FROM dataschool_project.population_UK_by_location_2024 pe; -- 357

SELECT pe.location_name FROM dataschool_project.population_UK_by_location_2024 pe
where location_name like '%lynn%';

#SELECT pe.location_name,  ld.lad25_name, ld.lad25_code
SELECT count(distinct(ld.lad25_code))
FROM dataschool_project.population_UK_by_location_2024 pe
JOIN dataschool_project.lad_dec_2025 ld
ON pe.location_name = ld.lad25_name; -- 317

SELECT *
FROM dataschool_project.population_UK_by_location_2024 pe
WHERE pe.location_name NOT IN (
	SELECT ld.lad25_name 
	FROM dataschool_project.lad_dec_2025 ld
);

SELECT distinct(geography_type) FROM dataschool_project.population_UK_by_location_2024;

SELECT count(distinct(location_name)) FROM dataschool_project.population_UK_by_location_2024
WHERE geography_type NOT IN ('Country', 'County', 'Region', 'Metropolitan County'); -- 318

-- Locations inside Population csv
Select *  
from dataschool_project.population_UK_by_location_2024
ORDER BY location_name;

-- All the locations but type: Region, Country, County, Metropolitan County 
Select geography_type, location_name, location_code
from dataschool_project.population_UK_by_location_2024
where geography_type NOT IN ('Region', 'Country', 'County', 'Metropolitan County');

SELECT location_name, 
CASE
	WHEN location_name LIKE CONCAT('%', @character13, '%') THEN 'Return'
	WHEN location_name LIKE CONCAT('%', @character10, '%') THEN 'Line Feed'
	WHEN location_name LIKE CONCAT('%', @character9, '%') THEN 'Tab'
    WHEN location_name LIKE CONCAT('%', @character34, '%') THEN 'Double Quotes'
    ELSE 'Empty'
END  
FROM dataschool_project.population_UK_by_location_2024
WHERE location_name LIKE CONCAT('%', @character13, '%') OR 
	location_name LIKE CONCAT('%', @character10, '%') OR 
	location_name LIKE CONCAT('%', @character9, '%') OR 
    location_name LIKE CONCAT('%',  @character34, '%'); 


