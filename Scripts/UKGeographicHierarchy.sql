
SHOW VARIABLES LIKE 'secure_file_priv';
SHOW VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;

CREATE TABLE uk_geographic_hierarchy (
place_id INT,
place_sort VARCHAR(100), 
place_description VARCHAR(4),
county_name_1961 VARCHAR(80),
county_name_1991 VARCHAR(80),
country VARCHAR(40),
county_code VARCHAR(11),
county_name_1921 VARCHAR(100),
local_authority_district_name VARCHAR(100),
local_authority_code VARCHAR(11),
latitude float,
longitude float
);


LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/PlasticRecyclingProject/Datasets/IPN_GB_2022_Summary.csv'
INTO TABLE dataschool_project.uk_geographic_hierarchy
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ####################################################

SELECT al.authority_convert, gh.place_description, al.location_code, local_authority_code, gh.county_code,  gh.latitude, gh.longitude, al.population
FROM dataschool_project.uk_geographic_hierarchy gh
JOIN dataschool_project.authority_locations_lookup al
ON gh.local_authority_code = al.location_code 
where gh.country = 'England';


