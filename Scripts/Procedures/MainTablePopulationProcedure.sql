DELIMITER $$

CREATE PROCEDURE main_population_table_procedure()
BEGIN

	-- Create Table
	CREATE TABLE dataschool_project.main_population_UK_by_location_2024 (
	location_code VARCHAR(15),
	location_name VARCHAR(100),
	geography_type VARCHAR(100),
	population INT);
    
END $$

DELIMITER ;
