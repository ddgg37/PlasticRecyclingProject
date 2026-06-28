
SET GLOBAL local_infile = 1;

CREATE TABLE authority_locations_lookup (
    authority_id INT,
    authority_name VARCHAR(80),
    authority_convert VARCHAR(80),
    location_code VARCHAR(80),
    location_name VARCHAR(80),
    geography_type VARCHAR(100),
    population INT
);

-- Populate Table from waste_collection_2025_summary
SELECT DISTINCT( 
	LTRIM(RTRIM(
	REGEXP_REPLACE(
		REGEXP_REPLACE(
			REGEXP_REPLACE(
				REGEXP_REPLACE(
					REGEXP_REPLACE(
						REGEXP_REPLACE(
							REGEXP_REPLACE(
								REGEXP_REPLACE(
									REGEXP_REPLACE(
										REGEXP_REPLACE(
											authority,
											'\\b(City Council|Borough\\s*|Council\\s*|Royal\\s*|District|Waste|Authority|\\s*WDA\\s*|(MBC)|MDC|LB)',
											''
										),
										'\\s+',
										' '
									),
									'\\s*\\([^)]*\\)',
									''
								),
								'-',
								' '
							),
							'\\s+City\\s+and',
							''
						),
						'^of\\s*',
						''
					),
					'\\s+Council$',
					''
				),
				' South Cambs .*',
				''
			),
			'\\s+City',
			''
		),
		'^the\\s+',
		''
	)    
))) as authority
FROM dataschool_project.waste_collection_2025_summary;
#where authority like '%Scilly%';
#where authority like '%kensington%';

-- we populate authority_convert in authority_locations_lookup
INSERT INTO authority_locations_lookup (authority_convert, authority_id, authority_name)
SELECT DISTINCT( 
	LTRIM(RTRIM(
	REGEXP_REPLACE(
		REGEXP_REPLACE(
			REGEXP_REPLACE(
				REGEXP_REPLACE(
					REGEXP_REPLACE(
						REGEXP_REPLACE(
							REGEXP_REPLACE(
								REGEXP_REPLACE(
									REGEXP_REPLACE(
										REGEXP_REPLACE(
											authority,
											'\\b(City Council|City$|Borough\\s*|Council\\s*|Royal\\s*|District|Waste|Authority|\\s*WDA\\s*|(MBC)|MDC|LB)',
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
							'\\s+City\\s+and',
							''
						),
						'^of\\s*',
						''
					),
					'\\s+Council$',
					''
				),
				' South Cambs .*',
				''
			),
			'\\s+City',
			''
		),
		'^the\\s+',
		''
	)    
	))), authority_id, authority 
FROM dataschool_project.waste_collection_2025_summary;

-- We update location code, name, geography type and  population
UPDATE dataschool_project.authority_locations_lookup al
JOIN dataschool_project.population_uk_by_location_2024 pe 
ON al.authority_convert = pe.location_name
SET
	al.location_name = pe.location_name,
    al.location_code = pe.location_code,
    al.geography_type = pe.geography_type,
    al.population = pe.population; 

-- ###Export Data for Comparison
SELECT
    'authority_id',
    'authority_name',
    'authority_convert',
    'location_code',
    'location_name',
    'geography_type',
    'population'
UNION ALL
SELECT
    authority_id,
    authority_name,
    authority_convert,
    location_code,
    location_name,
    geography_type,
    population
FROM dataschool_project.authority_locations_lookup
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ExportAuthorityLocationsLookup.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- Not sure if we need it: We add only Countries and the Regions for later calculations
#INSERT INTO dataschool_project.authority_locations_lookup (location_name,location_code,geography_type,population, authority_convert, authority_name)
#SELECT location_name,location_code,geography_type,population, location_name, location_name 
#FROM dataschool_project.population_england_wales_by_location 
#WHERE geography_type = 'Country' OR geography_type = 'Region';

-- ###########################################################################################

-- Lets check location lookup population, location name and code, 
#SELECT al.location_name, al.location_code,pe.location_code,pe.location_name,pe.geography_type,pe.population 
SELECT count(distinct(al.authority_convert)) 
FROM dataschool_project.authority_locations_lookup al
JOIN dataschool_project.population_england_wales_by_location pe 
ON al.authority_convert = pe.location_name; -- 291

SELECT count(distinct(authority_convert)) 
FROM dataschool_project.authority_locations_lookup
WHERE authority_convert NOT IN (
	SELECT location_name
	FROM dataschool_project.population_england_wales_by_location
); -- 30

SELECT count(distinct(authority_convert)) 
FROM dataschool_project.authority_locations_lookup
WHERE authority_convert IN (
	SELECT location_name
	FROM dataschool_project.population_england_wales_by_location
); -- 292

SELECT count(distinct(al.authority_convert)) 
FROM dataschool_project.authority_locations_lookup al
JOIN dataschool_project.lad_dec_2025 l2 
ON l2.lad25_name = al.authority_convert; -- 292

SELECT count(distinct(pe.location_code)) 
FROM dataschool_project.population_england_wales_by_location pe; -- 357

SELECT count(distinct(wc.authority_id)) 
FROM dataschool_project.waste_collection_2025_summary wc; -- 321

SELECT count(distinct(l2.lad25_code)) 
FROM dataschool_project.lad_dec_2025 l2; -- 361

SELECT count(distinct(al.authority_convert)) 
FROM dataschool_project.authority_locations_lookup al; -- 321

-- Other queries
SELECT * FROM dataschool_project.authority_locations_lookup;

SELECT authority_convert, location_code, location_name FROM dataschool_project.authority_locations_lookup;

SELECT COUNT(*) FROM dataschool_project.authority_locations_lookup
where geography_type NOT IN ('Country', 'County', 'Region', 'Metropolitan County'); -- 280

SELECT distinct(wc.authority_id),al.authority_name, wc.authority,al.location_code
FROM dataschool_project.authority_locations_lookup al
JOIN dataschool_project.waste_collection wc
ON al.authority_id = wc.authority_id
where al.geography_type IS NULL;

-- The authorities and ID
Select distinct(authority), authority_id
from dataschool_project.waste_collection;

-- ###############Clean up of special characters

Select count(distinct(authority))
from dataschool_project.waste_collection_2025; -- 322

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

SELECT *
FROM dataschool_project.waste_collection
WHERE authority IN (
    SELECT location_name
    FROM dataschool_project.population_england_wales_by_location
);
