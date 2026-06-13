SELECT * FROM dataschool_project.waste_collection;

Select distinct(Authority) 
from dataschool_project.waste_collection;

Select distinct(WasteStreamType) 
from dataschool_project.waste_collection; #Food waste


Select distinct(MaterialGroup) 
from dataschool_project.waste_collection
WHERE MaterialGroup IS NULL OR TRIM(MaterialGroup) = '';

-- To check the emty columns character length
SELECT
    MaterialGroup,
    LENGTH(MaterialGroup) AS len
FROM dataschool_project.waste_collection
WHERE MaterialGroup IS NOT NULL;

-- char 13 is return character
SET @character13 = CHAR(13);
-- char 10 is line feed
SET @character10 = CHAR(10);
-- char 9 is tab
SET @characterTab = CHAR(9);

-- This query shows what character contains in MaterialGroup
SELECT MaterialGroup, 
CASE
	WHEN MaterialGroup LIKE CONCAT('%', @character13, '%') THEN 'Return'
	WHEN MaterialGroup LIKE CONCAT('%', @character10, '%') THEN 'Line Feed'
	WHEN MaterialGroup LIKE CONCAT('%', @character9, '%') THEN 'Tab'
    ELSE 'Empty'
END  
FROM dataschool_project.waste_collection
WHERE MaterialGroup LIKE CONCAT('%', @character13, '%') OR 
	MaterialGroup LIKE CONCAT('%', @character10, '%') OR 
	MaterialGroup LIKE CONCAT('%', @character9, '%'); 

-- Remove Return, line feed or tab characters
UPDATE dataschool_project.waste_collection 
SET MaterialGroup = 
	TRIM(
		REPLACE(
			REPLACE(
				REPLACE(MaterialGroup, @character13, ''),
			@character10, ''),
		@character9, '')
	)
WHERE MaterialGroup LIKE CONCAT('%', @character13, '%')
   OR MaterialGroup LIKE CONCAT('%', @character10, '%')
   OR MaterialGroup LIKE CONCAT('%', @character9, '%');

-- Authorities with maximum tonnes recycling
Select MAX(TotalTonnes) AS Tonnes, 
MaterialGroup AS Material, 
Authority AS Authority,
Period AS Period
from dataschool_project.waste_collection  
GROUP BY MaterialGroup, Authority, Period 
HAVING MaterialGroup LIKE 'Tyres%'
ORDER BY Tonnes DESC;