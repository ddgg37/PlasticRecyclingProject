DELIMITER $$

CREATE PROCEDURE waste_collection_procedure()
BEGIN

	DECLARE start_time DATETIME; 
    DECLARE end_time DATETIME;
	#DECLARE @batch_start_time DATETIME; 
	#DECLARE @batch_end_time DATETIME;

	#SET @batch_start_time = GETDATE();
	-- Loading silver.crm_cust_info
	SET @start_time = GETDATE();
        
	-- Delete table
	#DROP TABLE IF EXISTS dataschool_project.waste_collection_temp;

	-- Create Table
	CREATE TEMPORARY TABLE dataschool_project.waste_collection_temp (
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
	INTO TABLE dataschool_project.waste_collection_temp
	FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;
    
    #SET @batch_end_time = GETDATE();
	-- Loading silver.crm_cust_info
	SET @end_time = GETDATE();
    
    SELECT "TIME COMPLETION: " + @end_time - @start_time;
    
END $$

DELIMITER ;