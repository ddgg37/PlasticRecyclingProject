
SELECT * FROM dataschool_project.waste_collection;
SELECT * FROM dataschool_project.population_england_wales_by_location;

-- The authorities and ID
Select * 
from dataschool_project.waste_collection
where authority like '%Blackpool%';

-- Locations inside Population csv
Select *  
from dataschool_project.population_england_wales_by_location
where geography_type = 'Unitary Authority'
ORDER BY location_name;

-- Waste Types
Select distinct(WasteStreamType) 
from dataschool_project.waste_collection; #Food waste

-- Checking material vs material_group
Select material, material_group 
from dataschool_project.waste_collection 
WHERE LOWER(TRIM(material)) != LOWER(TRIM(material_group));

Select distinct(material_group) 
from dataschool_project.waste_collection
WHERE material_group IS NULL OR TRIM(material_group) = '';

-- To check the emty columns character length
SELECT
    material_group,
    LENGTH(material_group) AS len
FROM dataschool_project.waste_collection
WHERE material_group IS NOT NULL;

-- ###############Clean up of special characters

-- char 13 is return character
SET @character13 = CHAR(13);
-- char 10 is line feed
SET @character10 = CHAR(10);
-- char 9 is tab
SET @characterTab = CHAR(9);

-- This query shows what character contains in MaterialGroup
SELECT material_group, 
CASE
	WHEN material_group LIKE CONCAT('%', @character13, '%') THEN 'Return'
	WHEN material_group LIKE CONCAT('%', @character10, '%') THEN 'Line Feed'
	WHEN material_group LIKE CONCAT('%', @character9, '%') THEN 'Tab'
    ELSE 'Empty'
END  
FROM dataschool_project.waste_collection
WHERE material_group LIKE CONCAT('%', @character13, '%') OR 
	material_group LIKE CONCAT('%', @character10, '%') OR 
	material_group LIKE CONCAT('%', @character9, '%'); 

-- Remove Return, line feed or tab characters
UPDATE dataschool_project.waste_collection 
SET material_group = 
		REPLACE(
			REPLACE(
				REPLACE(material_group, @character13, ''),
			@character10, ''),
		@character9, '') = ''
WHERE material_group LIKE CONCAT('%', @character13, '%')
   OR material_group LIKE CONCAT('%', @character10, '%')
   OR material_group LIKE CONCAT('%', @character9, '%');
-- ##########################

-- Clean up Authories
SELECT DISTINCT(RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Authority, 'Council', ''), 'Borough', ''), 'District',''), 'MBC',''), 'LB', ''), 'County', ''),'City',''),'Waste',''),'Authority',''),'WDA ()',''),'MDC ()',''),'MDC','')))) AS authority_converted 
FROM dataschool_project.waste_collection;

UPDATE dataschool_project.waste_collection
SET authority = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Authority, 'Council', ''), 'Borough', ''), 'District',''), 'MBC',''), 'LB', ''), 'County', ''),'City',''),'Waste',''),'Authority',''),'WDA ()',''),'MDC ()',''),'MDC','')));
-- #######################

-- Authorities with maximum tonnes recycling
Select MAX(total_tonnes) AS Tonnes, 
material_group AS Material, 
authority AS Authority,
period AS Period
from dataschool_project.waste_collection  
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
FROM dataschool_project.waste_collection AS wc 
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
		FROM dataschool_project.waste_collection AS wc 
        WHERE LOWER(wc.authority) = LOWER(pe.location_name) 
	) AS authority 
FROM dataschool_project.population_england_wales_by_location AS pe;

Select total_tonnes, 
material_group, 
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(authority, 'Council', ''), 'Borough', ''), 'District',''), 'MBC',''), 'LB', ''), 'County', ''),'City',''),'and','') AS authority_converted,
Period AS Period
FROM dataschool_project.waste_collection	
GROUP BY total_tonnes,material_group,authority_converted,period;
#WHERE authority_converted IS NOT NULL;

#TRIM(material_group) != '';
/* AND 
material_group NOT LIKE CONCAT('%', @character13, '%') AND 
material_group NOT LIKE CONCAT('%', @character10, '%') AND 
material_group NOT LIKE CONCAT('%', @character9, '%');*/

