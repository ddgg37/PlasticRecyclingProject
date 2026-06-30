
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;

-- Create Table
CREATE TABLE dataschool_project.local_authority_districts_2025 (
lad25_code VARCHAR(15),
lad25_name VARCHAR(100),
lad_nmw VARCHAR(100),
bng_e int,
bng_n int,
long_n int,
lat_n int,
global_id VARCHAR(100));

-- Import Data from csv file in my local machine
LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProject/Datasets/OriginalResources/LocalAuthorityDistricts/LAD_DEC_2025_UK_BGC.csv'
INTO TABLE dataschool_project.local_authority_districts_2025
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT 
	LTRIM(RTRIM(    
		REGEXP_REPLACE(
			REGEXP_REPLACE(
				REGEXP_REPLACE(
					REGEXP_REPLACE(
						REGEXP_REPLACE(
							lad25_name,
							', City of',
							''
						),
						', County of',
						''
					),
					'-',
					' '
				),
				'\\.',
				''
			),
			"'",
			''
		)
    )) as lad_name
FROM dataschool_project.local_authority_districts_2025;

-- We are only interested on England
UPDATE dataschool_project.local_authority_districts_2025
SET lad25_name = LTRIM(RTRIM(
		REGEXP_REPLACE(
			REGEXP_REPLACE(
				REGEXP_REPLACE(
					REGEXP_REPLACE(
						REGEXP_REPLACE(
							lad25_name,
							', City of',
							''
						),
						', County of',
						''
					),
					'-',
					' '
				),
				'\\.',
				''
			),
			"'",
			''
		)
    ));

-- ##############################################################################


select lad25_code, lad25_name from dataschool_project.local_authority_districts_2025
where lad25_code like 'E%';

SELECT count(distinct(lad25_code)) FROM dataschool_project.local_authority_districts_2025
where lad25_code like 'E%'; -- 296

SELECT lad25_code, lad25_name FROM dataschool_project.local_authority_districts_2025
where lad25_code like 'E%'
order by lad25_code;

SELECT count(distinct(location_code)) FROM dataschool_project.authority_locations_lookup
where location_code like 'E%'; -- 318

SELECT location_code, location_name  
FROM dataschool_project.authority_locations_lookup 
where location_code like 'E%'
order by location_code;
