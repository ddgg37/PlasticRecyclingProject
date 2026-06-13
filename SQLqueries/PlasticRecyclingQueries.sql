

SHOW VARIABLES LIKE 'secure_file_priv';
SHOW VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;

#Create Schema
CREATE SCHEMA IF NOT EXISTS dataschool_project;

#Create Table
CREATE TABLE dataschool_project.waste_collection (
WasteProcessorId INT,
WasteStreamId INT,
WasteProcessorOutputId INT,
SenderWasteProcessorOutputId INT,
Authority VARCHAR(255),
AuthorityId INT,
Period VARCHAR(20),
PeriodId INT,
WasteStreamTypeId INT,
WasteStreamType VARCHAR(80),
FacilityTypeId INT,
FacilityType VARCHAR(80),
NationalFacilityId INT,
FacilityName VARCHAR(80),
FacilityAddress VARCHAR(255),
FacilityPostCode VARCHAR(10),
FacilityLicence VARCHAR(80),
FacilityCode VARCHAR(10),
OutputProcessTypeId INT,
OutputProcessType VARCHAR(80),
TotalTonnes FLOAT,
MaterialId INT,
Material VARCHAR(50),
TonnesByMaterial FLOAT,
TonnesFromHHSources FLOAT,
TonnesFromCommercialSources FLOAT,
TonnesFromIndustrialSources FLOAT,
TonnesFromNonHHSources FLOAT,
TonnesFromWfHSources FLOAT,
TonnesFromWnfHSources FLOAT,
UsageId INT,
`Usage` VARCHAR(50),
QuarterlyComments VARCHAR(255),
MonthlyComments VARCHAR(255),
MaterialGroup VARCHAR(80));

#Import Data from csv file
LOAD DATA LOCAL INFILE 'C:/Users/aDesktop/Development/DataSchoolProject/Data/Q100+Waste+Collectink+data+England+2024-25.csv'
INTO TABLE dataschool_project.waste_collection
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

