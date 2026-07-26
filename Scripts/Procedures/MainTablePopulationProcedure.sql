
-- ###################################################################
-- THIS IS THE PROCCEDURE TO CREATE AND LOAD DATA OF UK POPULATION BASED ON LOCATION CODE
-- ###################################################################

DELIMITER $$

CREATE PROCEDURE main_population_table_procedure()
BEGIN

	DROP TABLE IF EXISTS dataschool_project.main_population_UK_by_location_2024;
 
	-- Create Table
	CREATE TABLE dataschool_project.main_population_UK_by_location_2024 (
	location_code VARCHAR(15),
	location_name VARCHAR(100),
	geography_type VARCHAR(100),
	population INT);
    
    LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProject/Datasets/UKPopulationByAuthority2024.csv'
	INTO TABLE dataschool_project.main_population_UK_by_location_2024
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;
    
    
    
END $$

DELIMITER ;
