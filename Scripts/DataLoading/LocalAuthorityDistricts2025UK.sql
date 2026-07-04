
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
