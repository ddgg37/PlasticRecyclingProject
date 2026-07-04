
SELECT * FROM dataschool_project.waste_collection_2025;
SELECT * FROM dataschool_project.population_england_wales_by_location;

-- The authorities and ID
Select * 
from dataschool_project.waste_collection_2025
where authority like '%Blackpool%';

-- Locations inside Population csv
Select *  
from dataschool_project.population_england_wales_by_location
where geography_type = 'Unitary Authority'
ORDER BY location_name;

-- Waste Types
Select distinct(WasteStreamType) 
from dataschool_project.waste_collection_2025; #Food waste

-- Checking material vs material_group
Select material, material_group 
from dataschool_project.waste_collection_2025 
WHERE LOWER(TRIM(material)) != LOWER(TRIM(material_group));

Select distinct(material_group) 
from dataschool_project.waste_collection_2025
WHERE material_group IS NULL OR TRIM(material_group) = '';

-- To check the emty columns character length
SELECT
    material_group,
    LENGTH(material_group) AS len
FROM dataschool_project.waste_collection_2025
WHERE material_group IS NOT NULL;

-- Authorities with maximum tonnes recycling
Select MAX(total_tonnes) AS Tonnes, 
material_group AS Material, 
authority AS Authority,
period AS Period
from dataschool_project.waste_collection_2025  
GROUP BY material_group, authority, period 
#HAVING material_group LIKE 'Tyres%' AND authority LIKE '%Somerset%'
ORDER BY Tonnes DESC;

SELECT COUNT(DISTINCT(location_name)) 
FROM dataschool_project.population_england_wales_by_location
WHERE geography_type LIKE '%Authority%';

-- Joining both tables 
Select MAX(TotalTonnes) AS Tonnes, 
material_group AS Material, 
Authotity AS Authotity,
Period AS Period
FROM dataschool_project.waste_collection_2025 AS wc 
JOIN dataschool_project.population_england_wales_by_location AS pe
ON LOWER(wc.authority) = LOWER(pe.location_name)
GROUP BY material_group, Authority, Period 
HAVING material_group LIKE 'Tyres%' AND Authority LIKE '%Somerset%'
ORDER BY Tonnes DESC;

-- Joining both tables 
SELECT total_tonnes AS Tonnes, 
	material_group AS Material, 
    (
		Select authority 
		FROM dataschool_project.waste_collection_2025 AS wc 
        WHERE LOWER(wc.authority) = LOWER(pe.location_name) 
	) AS authority 
FROM dataschool_project.population_england_wales_by_location AS pe;

Select total_tonnes, 
material_group, 
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(authority, 'Council', ''), 'Borough', ''), 'District',''), 'MBC',''), 'LB', ''), 'County', ''),'City',''),'and','') AS authority_converted,
Period AS Period
FROM dataschool_project.waste_collection_2025	
GROUP BY total_tonnes,material_group,authority_converted,period;
#WHERE authority_converted IS NOT NULL;

-- To sort out

select count(*) from local_authority_districts_2025;

select count(*) from local_authority_districts_2025
where lad25_code LIKE 'E%';

select count(*) from local_authority_districts_2025 ad
JOIN authority_locations_lookup al
ON al.location_code = ad.lad25_code 
WHERE ad.lad25_code LIKE 'E%';

select * from local_authority_districts_2025 ad
where lad25_name LIKE '%Barnsley%'; -- 'E08000038'

SELECT distinct(authority) 
FROM dataschool_project.waste_collection_2025_summary
where authority LIKE '%Gateshead%'; -- 'E08000038'

SELECT * FROM dataschool_project.authority_locations_lookup al
where authority_convert LIKE '%Gateshead%'; -- 'E08000016'

SELECT * FROM dataschool_project.authority_locations_lookup al
JOIN local_authority_districts_2025 ad
ON al.location_code = ad.lad25_code;
#where location_code = '%E08000016%';

SELECT * 
FROM dataschool_project.waste_collection_2025_summary
where authority LIKE '%Barnsley%';

SELECT * FROM dataschool_project.authority_locations_lookup al
where authority_convert LIKE '%Barnsley%';

SELECT * FROM dataschool_project.local_authority_districts_2025 
where lad25_name LIKE '%Barnsley%';

SELECT * FROM dataschool_project.population_uk_by_location_2024
where location_name LIKE '%Tynesideauthority_locations_lookup%';

select * from local_authority_districts_2025 ad
JOIN authority_locations_lookup al
ON al.location_code = ad.lad25_code 
WHERE ad.lad25_code LIKE 'E%';
    
SELECT * FROM dataschool_project.authority_locations_lookup
#where location_name IS NULL;
where location_name LIKE '%Manchester%';

SELECT * 
FROM dataschool_project.waste_collection_2025_summary
where authority LIKE '%Manchester%';

SELECT * FROM dataschool_project.population_uk_by_location_2024
where location_name LIKE '%Manchester%';

SELECT * FROM dataschool_project.authority_locations_lookup
where location_name IS NULL;


