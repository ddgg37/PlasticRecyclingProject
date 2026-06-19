
-- Call Procedure to create temp table
CALL dataschool_project.waste_collection_table_procedure();

SHOW PROCEDURE STATUS
WHERE Db = 'dataschool_project';

-- Import Data from csv file from local machine
LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProject/Datasets/Q100+Waste+Collectink+data+England+2024-25.csv'
INTO TABLE dataschool_project.waste_collection
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;