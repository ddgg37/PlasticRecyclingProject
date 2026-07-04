DELIMITER $$

CREATE PROCEDURE main_local_authority_table_procedure()
BEGIN

	CREATE TABLE dataschool_project.main_local_authority_districts_2025 (
	lad25_code VARCHAR(15),
	lad25_name VARCHAR(100),
	lad_nmw VARCHAR(100),
	bng_e int,
	bng_n int,
	long_n int,
	lat_n int,
	global_id VARCHAR(100));
    
END $$

DELIMITER ;
