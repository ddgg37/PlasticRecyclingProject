
-- Call Procedure to create temp table
CALL dataschool_project.waste_collection_table_procedure();
#CALL dataschool_project.population_UK_by_location_procedure();
#CALL dataschool_project.local_authority_districts_procedure();

SHOW PROCEDURE STATUS
WHERE Db = 'dataschool_project';

-- Import Data from csv file to Waste Collection Main Table
LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProject/Datasets/OriginalResources/Q100+Waste+Collectink+data+England+2024-25.csv'
INTO TABLE dataschool_project.waste_collection_2025
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Import Data from csv file to Population Main Table
LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProject/Datasets/OriginalResources/UKPopulationByAuthority2024.csv'
INTO TABLE dataschool_project.population_UK_by_location_2024
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

