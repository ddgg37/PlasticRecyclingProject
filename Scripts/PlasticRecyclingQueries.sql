
SHOW VARIABLES LIKE 'secure_file_priv';
SHOW VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;

-- Create Schema
CREATE SCHEMA IF NOT EXISTS dataschool_project;

-- Set as default Schema
USE dataschool_project;

-- Call Procedure to create temp table
#CALL dataschool_project.waste_collection_table_temp_procedure();
CALL dataschool_project.waste_collection_table_procedure();

SHOW PROCEDURE STATUS
WHERE Db = 'dataschool_project';

-- Import Data from csv file from local machine
LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProject/Datasets/Q100+Waste+Collectink+data+England+2024-25.csv'
>>>>>>> DataAnalysisProcess
INTO TABLE dataschool_project.waste_collection
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ############################### FINAL DB #########################################

-- Delete table
DROP TABLE IF EXISTS dataschool_project.waste_collection;

-- Create Table
CREATE TABLE dataschool_project.waste_collection_stage (
waste_processor_id INT,
waste_stream_id INT,
waste_processor_output_id INT,
sender_waste_processor_output_id INT,
authority VARCHAR(255),
authority_id INT,
period VARCHAR(20),
period_id INT,
waste_stream_type_id INT,
waste_stream_type VARCHAR(80),
facility_type_id INT,
facility_type VARCHAR(80),
national_facility_id INT,
facility_name VARCHAR(80),
facility_address VARCHAR(255),
facility_postCode VARCHAR(10),
facility_licence VARCHAR(80),
facility_code VARCHAR(10),
output_process_type_id INT,
output_process_type VARCHAR(80),
total_tonnes FLOAT,
material_id INT,
material VARCHAR(50),
tonnes_by_material FLOAT,
tonnes_from_HH_sources FLOAT,
tonnes_from_commercial_sources FLOAT,
tonnes_from_industrial_sources FLOAT,
tonnes_from_non_HH_sources FLOAT,
tonnes_from_WfH_sources FLOAT,
tonnes_from_WnfH_sources FLOAT,
usage_id INT,
`usage` VARCHAR(50),
quarterly_comments VARCHAR(255),
monthly_comments VARCHAR(255),
material_group VARCHAR(80));

-- Import Data from csv file from local machine
LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProject/Datasets/Q100+Waste+Collectink+data+England+2024-25.csv'
INTO TABLE dataschool_project.waste_collection_stage
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

