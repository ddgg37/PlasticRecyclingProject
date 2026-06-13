SELECT * FROM dataschool_project.waste_collection;

Select distinct(Authority) 
from dataschool_project.waste_collection;

Select distinct(WasteStreamType) 
from dataschool_project.waste_collection; #Food waste

Select distinct(MaterialGroup) 
from dataschool_project.waste_collection
WHERE TRIM(MaterialGroup) != '';


Select MAX(TotalTonnes) AS Tonnes, 
MaterialGroup AS Material, 
Authority AS Authority,
Period AS Period
from dataschool_project.waste_collection  
GROUP BY MaterialGroup, Authority, Period 
HAVING MaterialGroup LIKE 'Tyres%'
ORDER BY Tonnes DESC;