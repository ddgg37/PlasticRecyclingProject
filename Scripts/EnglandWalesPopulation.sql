
-- Create Table
CREATE TABLE dataschool_project.population_england_wales_by_location (
location_code VARCHAR(15),
location_name VARCHAR(100),
geography_type VARCHAR(100),
population INT);

-- Import Data from csv file in my local machine
LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProject/Datasets/EnglandWalesPopulationByAuthority.csv'
INTO TABLE dataschool_project.population_england_wales_by_location
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

