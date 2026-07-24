
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



