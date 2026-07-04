
SHOW VARIABLES LIKE 'secure_file_priv';
SHOW VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;

-- Create Schema
CREATE SCHEMA IF NOT EXISTS dataschool_project;

-- Set as default Schema
USE dataschool_project;

-- Call Procedure to create temp table
CALL dataschool_project.main_local_authority_table_procedure();
CALL dataschool_project.main_population_table_procedure();
CALL dataschool_project.main_waste_collection_table_procedure();

SHOW PROCEDURE STATUS
WHERE Db = 'dataschool_project';

-- Import Data from csv file to Waste Collection Main Table
LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProject/Datasets/OriginalResources/Q100+Waste+Collectink+data+England+2024-25.csv'
INTO TABLE dataschool_project.main_waste_collection_2025
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Import Data from csv file to Population Main Table
LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProject/Datasets/OriginalResources/UKPopulationByAuthority2024.csv'
INTO TABLE dataschool_project.main_population_UK_by_location_2024
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Import Data from csv file to Local Authority Table
LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProject/Datasets/OriginalResources/LocalAuthorityDistricts/LAD_DEC_2025_UK_BGC.csv'
INTO TABLE dataschool_project.main_local_authority_districts_2025
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

