CREATE TABLE authority_locations_lookup (
    authority_id INT,
    authority_name VARCHAR(80),
    authority_convert VARCHAR(80),
    location_code VARCHAR(80),
    location_name VARCHAR(80),
    geography_type VARCHAR(100),
    population INT
);

-- Populate Table
SELECT DISTINCT( 
	LTRIM(RTRIM(
    REGEXP_REPLACE(
		REGEXP_REPLACE(
			REGEXP_REPLACE(
				REGEXP_REPLACE(
					REGEXP_REPLACE(
						REGEXP_REPLACE(
							authority,
							'\\b(Council( of)?|Royal|Borough( of)?|District|City( of)?|County|Waste|Authority|WDA|MBC|MDC|LB)',
							''
						),
						'\\s+',
						' '
					),
					'\\s*\\([^)]*\\)',
					''
				),
				'\\s*-\\s*',
				' '
			),
			'\\s+and\\s$',
			''
		),
		'^of\\s*',
		''
		)
)))
FROM dataschool_project.waste_collection;


INSERT INTO authority_locations_lookup (authority_convert, authority_id, authority_name)
SELECT DISTINCT( 
	LTRIM(RTRIM(
    REGEXP_REPLACE(
		REGEXP_REPLACE(
			REGEXP_REPLACE(
				REGEXP_REPLACE(
					REGEXP_REPLACE(
						REGEXP_REPLACE(
							authority,
							'\\b(Council( of)?|Royal|Borough( of)?|District|City( of)?|County|Waste|Authority|WDA|MBC|MDC|LB)',
							''
						),
						'\\s+',
						' '
					),
					'\\s*\\([^)]*\\)',
					''
				),
				'\\s*-\\s*',
				' '
			),
			'\\s+and\\s$',
			''
		),
		'^of\\s*',
		''
	)
))), authority_id, authority 
FROM dataschool_project.waste_collection
WHERE authority_id != 0; -- authority id 0 is empty record

-- We add the Countries and the Regions for later calculations
INSERT INTO authority_locations_lookup (location_name,location_code,geography_type,population, authority_convert, authority_name)
SELECT location_name,location_code,geography_type,population, location_name, location_name 
FROM dataschool_project.population_england_wales_by_location
WHERE geography_type = 'Country' OR geography_type = 'Region';

UPDATE authority_locations_lookup al
JOIN dataschool_project.population_england_wales_by_location pe
ON al.authority_convert = LTRIM(RTRIM(
		REGEXP_REPLACE(
			REGEXP_REPLACE(
				REGEXP_REPLACE(
					REGEXP_REPLACE(
						pe.location_name,
						'\\b(City( of)?)',
						''
					),
					'\\s+',
					' '
				),
				'\\s*\\([^)]*\\)',
				''
			),
			'\\s*[-.]\\s*',
			' '
		)
    ))
SET 
	al.location_name = pe.location_name,
    al.location_code = pe.location_code,
    al.geography_type = pe.geography_type,
    al.population = pe.population;

-- Other queries
SELECT * FROM dataschool_project.authority_locations_lookup;

SELECT COUNT(*) FROM dataschool_project.authority_locations_lookup
where geography_type NOT IN ('Country', 'County', 'Region', 'Metropolitan County'); -- 280

SELECT distinct(wc.authority_id),al.authority_name, wc.authority,al.location_code
FROM dataschool_project.authority_locations_lookup al
JOIN dataschool_project.waste_collection wc
ON al.authority_id = wc.authority_id
where al.geography_type IS NULL;

SELECT distinct(geography_type) FROM dataschool_project.population_england_wales_by_location;

SELECT count(distinct(location_name)) FROM dataschool_project.population_england_wales_by_location
WHERE geography_type NOT IN ('Country', 'County', 'Region', 'Metropolitan County'); -- 318

-- Export Data for Comparison
SELECT * 
FROM dataschool_project.authority_locations_lookup
WHERE geography_type IS NULL
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/outputLocationsNullGeography.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

SELECT DISTINCT(location_name)
FROM dataschool_project.population_england_wales_by_location
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/outputLocation.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';


SELECT * FROM dataschool_project.authority_locations_lookup;

-- The authorities and ID
Select distinct(authority), authority_id
from dataschool_project.waste_collection;

-- Locations inside Population csv
Select *  
from dataschool_project.population_england_wales_by_location
ORDER BY location_name;

-- All the locations but type: Region, Country, County, Metropolitan County 
Select geography_type, location_name, location_code
from dataschool_project.population_england_wales_by_location
where geography_type NOT IN ('Region', 'Country', 'County', 'Metropolitan County');

-- ###############Clean up of special characters
-- char 13 is return character
SET @character13 = CHAR(13);
-- char 10 is line feed
SET @character10 = CHAR(10);
-- char 9 is tab
SET @characterTab = CHAR(9);

-- This query shows what character contains in MaterialGroup
SELECT Authority, 
CASE
	WHEN Authority LIKE CONCAT('%', @character13, '%') THEN 'Return'
	WHEN Authority LIKE CONCAT('%', @character10, '%') THEN 'Line Feed'
	WHEN Authority LIKE CONCAT('%', @character9, '%') THEN 'Tab'
    ELSE 'Empty'
END  
FROM dataschool_project.waste_collection
WHERE Authority LIKE CONCAT('%', @character13, '%') OR 
	Authority LIKE CONCAT('%', @character10, '%') OR 
	Authority LIKE CONCAT('%', @character9, '%'); 
    
SELECT location_name, 
CASE
	WHEN location_name LIKE CONCAT('%', @character13, '%') THEN 'Return'
	WHEN location_name LIKE CONCAT('%', @character10, '%') THEN 'Line Feed'
	WHEN location_name LIKE CONCAT('%', @character9, '%') THEN 'Tab'
    ELSE 'Empty'
END  
FROM dataschool_project.population_england_wales_by_location
WHERE location_name LIKE CONCAT('%', @character13, '%') OR 
	location_name LIKE CONCAT('%', @character10, '%') OR 
	location_name LIKE CONCAT('%', @character9, '%'); 
    
-- Check the data is successfully imported
-- Check number of different location in Waste Data

Select count(distinct(authority))
from dataschool_project.waste_collection; -- 322

Select count(distinct(location_name))
from dataschool_project.population_england_wales_by_location
where geography_type NOT IN ('Region', 'Country', 'County', 'Metropolitan County'); -- 318

-- ###############UTILITIES

/*
SELECT DISTINCT(authority)
FROM dataschool_project.waste_collection as pw 
WHERE EXISTS (
	SELECT 1
	FROM dataschool_project.population_england_wales_by_location AS pe
    #WHERE pe.location_name LIKE CONCAT('%',pw.authority,'%')
    WHERE INSTR(pe.location_name, pw.authority) > 0
    #LIMIT 100
    #WHERE pw.authority = pe.location_name
);


select authority 
FROM dataschool_project.waste_collection;

SELECT location_name
FROM dataschool_project.population_england_wales_by_location AS pe;

SELECT *
FROM dataschool_project.waste_collection
WHERE authority IN (
    SELECT location_name
    FROM dataschool_project.population_england_wales_by_location
);
