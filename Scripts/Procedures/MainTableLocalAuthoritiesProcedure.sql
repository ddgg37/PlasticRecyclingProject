
-- ###################################################################
-- THIS IS THE PROCEDURE THAT WILL CREATE AND LOAD DATA FOR THE UK AUTHORITY CODES AND NAMES
-- ###################################################################

DELIMITER $$

CREATE PROCEDURE main_local_authority_table_procedure()
BEGIN

	DROP TABLE IF EXISTS dataschool_project.main_local_authority_districts_2025;

	CREATE TABLE dataschool_project.main_local_authority_districts_2025 (
	lad25_code VARCHAR(15),
	lad25_name VARCHAR(100),
	lad_nmw VARCHAR(100),
	bng_e int,
	bng_n int,
	long_n int,
	lat_n int,
	global_id VARCHAR(100));
    
    LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProject/Datasets/OriginalResources/LocalAuthorityDistricts/OriginalResources/LAD_DEC_2025_UK_BGC.csv'
    INTO TABLE dataschool_project.main_local_authority_districts_2025
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;
    
    
END $$

DELIMITER ;
