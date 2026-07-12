
CREATE TABLE waste_collection_23_25_summary (
waste_processor_id INT,
authority VARCHAR(255), 
authority_id INT,
period_id INT,
period_start DATE,
period_end DATE,
waste_stream_type_id INT,
waste_stream_type VARCHAR(80),
facility_type_id INT,
facility_type VARCHAR(80),
national_facility_id INT,
facility_name VARCHAR(80),
facility_postCode VARCHAR(10),
total_tonnes FLOAT,
material_group VARCHAR(80),
material_id INT,
material VARCHAR(50),
tonnes_by_material FLOAT
);

INSERT INTO waste_collection_23_25_summary
SELECT 
	waste_processor_id,
	authority, 
	authority_id,
	period_id,
    STR_TO_DATE(CONCAT(TRIM(SUBSTRING_INDEX(period, ' - ', 1)), ' 01'), '%b %y %d'),
    STR_TO_DATE(CONCAT(TRIM(SUBSTRING_INDEX(period, ' - ', -1)), ' 01'), '%b %y %d'),
	waste_stream_type_id,
	waste_stream_type,
	facility_type_id,
	facility_type,
	national_facility_id,
	facility_name,
	facility_postCode,
	total_tonnes,
	material_group,
	material_id,
	material,
	tonnes_by_material
FROM dataschool_project.main_waste_collection_2025
where waste_processor_id != 0;

-- Clean up Authories
SELECT DISTINCT(RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Authority, 'Council', ''), 'Borough', ''), 'District',''), 'MBC',''), 'LB', ''), 'County', ''),'City',''),'Waste',''),'Authority',''),'WDA ()',''),'MDC ()',''),'MDC','')))) AS authority_converted 
FROM dataschool_project.waste_collection_23_25_summary;

UPDATE dataschool_project.waste_collection_23_25_summary
SET authority = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Authority, 'Council', ''), 'Borough', ''), 'District',''), 'MBC',''), 'LB', ''), 'County', ''),'City',''),'Waste',''),'Authority',''),'WDA ()',''),'MDC ()',''),'MDC','')));

-- char 13 is return character
SET @character13 = CHAR(13);
-- char 10 is line feed
SET @character10 = CHAR(10);
-- char 9 is tab
SET @character9 = CHAR(9);

-- This query shows what character contains in MaterialGroup
SELECT material_group, 
CASE
	WHEN material_group LIKE CONCAT('%', @character13, '%') THEN 'Return'
	WHEN material_group LIKE CONCAT('%', @character10, '%') THEN 'Line Feed'
	WHEN material_group LIKE CONCAT('%', @character9, '%') THEN 'Tab'
    ELSE 'Empty'
END  
FROM dataschool_project.waste_collection_23_25_summary
WHERE material_group LIKE CONCAT('%', @character13, '%') OR 
	material_group LIKE CONCAT('%', @character10, '%') OR 
	material_group LIKE CONCAT('%', @character9, '%'); 

-- Remove Return, line feed or tab characters
UPDATE dataschool_project.waste_collection_23_25_summary 
SET material_group = 
		REPLACE(
			REPLACE(
				REPLACE(material_group, @character13, ''),
			@character10, ''),
		@character9, '')
WHERE material_group LIKE CONCAT('%', @character13, '%')
   OR material_group LIKE CONCAT('%', @character10, '%')
   OR material_group LIKE CONCAT('%', @character9, '%');


-- ###################################################################

-- Export Data for Tableau
SELECT
	'waste_processor_id',
	'authority', 
	'authority_id',
	'period_id',
    'period_start',
	'period_end',
	'waste_stream_type_id',
	'waste_stream_type',
	'facility_type_id',
	'facility_type',
	'national_facility_id',
	'facility_name',
	'facility_postCode',
	'total_tonnes',
	'material_group',
	'material_id',
	'material',
	'tonnes_by_material'
UNION ALL
SELECT
	waste_processor_id,
	authority, 
	authority_id,
	period_id,
    period_start,
	period_end,
	waste_stream_type_id,
	waste_stream_type,
	facility_type_id,
	facility_type,
	national_facility_id,
	facility_name,
	facility_postCode,
	total_tonnes,
	material_group,
	material_id,
	material,
	tonnes_by_material    
FROM dataschool_project.waste_collection_23_25_summary
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ExportFromDBWasteCollectionSummary.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';



-- #################################QUERIES RELATED TO SEASONAL MATERIAL PERIODS #######################################

WITH cleaned AS (
    SELECT
        material_group,
        period_start,
        CASE MONTH(period_start)
            WHEN 4  THEN 'Q1 (Apr-Jun)'
            WHEN 7  THEN 'Q2 (Jul-Sep)'
            WHEN 10 THEN 'Q3 (Oct-Dec)'
            WHEN 1  THEN 'Q4 (Jan-Mar)'
        END AS fiscal_quarter,
        CASE
            WHEN MONTH(period_start) >= 4 THEN YEAR(period_start)
            ELSE YEAR(period_start) - 1
        END AS fiscal_year,
        SUM(tonnes_by_material) AS total_tonnes
    FROM waste_collection_23_25_summary
    WHERE facility_type <> 'Final Destination'
      AND tonnes_by_material > 0
    GROUP BY material_group, period_start
),
ranked AS (
    SELECT
        *,
        RANK() OVER (PARTITION BY material_group, fiscal_year ORDER BY total_tonnes DESC) AS peak_rank,
        RANK() OVER (PARTITION BY material_group, fiscal_year ORDER BY total_tonnes ASC)  AS trough_rank
    FROM cleaned
),
peaks_troughs AS (
    SELECT
        material_group,
        fiscal_year,
        MAX(CASE WHEN peak_rank = 1 THEN fiscal_quarter END)  AS peak_quarter,
        MAX(CASE WHEN peak_rank = 1 THEN total_tonnes END)    AS peak_tonnes,
        MAX(CASE WHEN trough_rank = 1 THEN fiscal_quarter END) AS trough_quarter,
        MAX(CASE WHEN trough_rank = 1 THEN total_tonnes END)   AS trough_tonnes
    FROM ranked
    GROUP BY material_group, fiscal_year
)
-- Part 1: peak/trough detail per material, per year
SELECT
    material_group,
    fiscal_year,
    peak_quarter,
    ROUND(peak_tonnes, 0)   AS peak_tonnes,
    trough_quarter,
    ROUND(trough_tonnes, 0) AS trough_tonnes,
    ROUND((peak_tonnes - trough_tonnes) / trough_tonnes * 100, 1) AS swing_pct
FROM peaks_troughs
ORDER BY material_group, fiscal_year;


-- ########################################################################

WITH cleaned AS (
    SELECT
        material_group,
        period_start,
        CASE MONTH(period_start)
            WHEN 4  THEN 'Q1 (Apr-Jun)'
            WHEN 7  THEN 'Q2 (Jul-Sep)'
            WHEN 10 THEN 'Q3 (Oct-Dec)'
            WHEN 1  THEN 'Q4 (Jan-Mar)'
        END AS fiscal_quarter,
        CASE
            WHEN MONTH(period_start) >= 4 THEN YEAR(period_start)
            ELSE YEAR(period_start) - 1
        END AS fiscal_year,
        SUM(tonnes_by_material) AS total_tonnes
    FROM waste_collection_23_25_summary
    WHERE facility_type <> 'Final Destination'
      AND tonnes_by_material > 0
    GROUP BY material_group, period_start
),
ranked AS (
    SELECT *,
        RANK() OVER (PARTITION BY material_group, fiscal_year ORDER BY total_tonnes DESC) AS peak_rank
    FROM cleaned
),
peak_quarters AS (
    SELECT material_group, fiscal_year, fiscal_quarter
    FROM ranked
    WHERE peak_rank = 1
)
SELECT
    material_group,
    COUNT(DISTINCT fiscal_year)    AS years_covered,
    COUNT(DISTINCT fiscal_quarter) AS distinct_peak_quarters,
    GROUP_CONCAT(DISTINCT fiscal_quarter ORDER BY fiscal_year) AS peak_quarter_by_year,
    CASE
        WHEN COUNT(DISTINCT fiscal_quarter) = 1 THEN 'Consistent — likely genuine seasonal pattern'
        ELSE 'Inconsistent — probably not seasonal'
    END AS verdict
FROM peak_quarters
GROUP BY material_group
ORDER BY verdict, material_group;

-- #####BIGGEST SEASONAL SWINGS ########

SELECT
    material_group,
    material,
    fiscal_year,
    peak_quarter,
    ROUND(peak_tonnes, 0)   AS peak_tonnes,
    trough_quarter,
    ROUND(trough_tonnes, 0) AS trough_tonnes,
    ROUND((peak_tonnes - trough_tonnes) / trough_tonnes * 100, 1) AS swing_pct
FROM peaks_troughs
ORDER BY swing_pct DESC;   -- biggest seasonal swings first

--  MORE USEFUL

WITH cleaned AS (
    SELECT
        material,
        period_start,
        CASE MONTH(period_start)
            WHEN 4  THEN 'Q1 (Apr-Jun)'
            WHEN 7  THEN 'Q2 (Jul-Sep)'
            WHEN 10 THEN 'Q3 (Oct-Dec)'
            WHEN 1  THEN 'Q4 (Jan-Mar)'
        END AS fiscal_quarter,
        CASE WHEN MONTH(period_start) >= 4 THEN YEAR(period_start) ELSE YEAR(period_start) - 1 END AS fiscal_year,
        SUM(tonnes_by_material) AS total_tonnes
    FROM waste_collection_23_25_summary
    WHERE facility_type <> 'Final Destination'
      AND tonnes_by_material > 0
    GROUP BY material, period_start
),
ranked AS (
    SELECT *,
        RANK() OVER (PARTITION BY material, fiscal_year ORDER BY total_tonnes DESC) AS peak_rank,
        RANK() OVER (PARTITION BY material, fiscal_year ORDER BY total_tonnes ASC)  AS trough_rank
    FROM cleaned
),
peak_quarters AS (
    SELECT material, fiscal_year, fiscal_quarter,
           MAX(CASE WHEN peak_rank=1 THEN total_tonnes END)   AS peak_tonnes,
           MAX(CASE WHEN trough_rank=1 THEN total_tonnes END) AS trough_tonnes
    FROM ranked
    WHERE peak_rank = 1 OR trough_rank = 1
    GROUP BY material, fiscal_year, fiscal_quarter
),
verdict AS (
    SELECT
        material,
        COUNT(DISTINCT fiscal_quarter) AS distinct_peak_quarters,
        AVG((peak_tonnes - trough_tonnes) / NULLIF(trough_tonnes,0) * 100) AS avg_swing_pct
    FROM peak_quarters
    GROUP BY material
)
SELECT
    material,
    ROUND(avg_swing_pct, 1) AS avg_swing_pct
FROM verdict
WHERE distinct_peak_quarters = 1        -- only genuinely consistent (seasonal) materials
ORDER BY avg_swing_pct DESC;            -- strongest seasonal swing first

SELECT
    material,
    period_start,
    period_id,
    SUM(tonnes_by_material) AS total_tonnes
FROM waste_collection_23_25_summary
WHERE facility_type <> 'Final Destination'
  AND tonnes_by_material > 0
  AND material IN ('Mixed cans', 'Green glass')
GROUP BY material, period_start, period_id
ORDER BY material, period_start;

SELECT
    w.material,
    w.period_start,
    w.period_id,
    SUM(w.tonnes_by_material) AS total_tonnes
FROM waste_collection_23_25_summary w
JOIN authority_locations_lookup al
    ON w.authority_id = al.authority_id
WHERE w.facility_type <> 'Final Destination'
  AND w.tonnes_by_material > 0
  AND w.material IN ('Mixed cans', 'Green glass')
  AND al.geography_type IN ('Unitary Authority', 'Non-metropolitan District', 'Metropolitan District', 'London Borough')
GROUP BY w.material, w.period_start, w.period_id
ORDER BY w.material, w.period_start;





--  ###############################GNERAL QUERIES##########################

SELECT distinct(authority)  
FROM dataschool_project.waste_collection_23_25_summary;

-- Data Analisys
SELECT DISTINCT(material),material_group,authority, period_id, period, tonnes_by_material, total_tonnes 
FROM dataschool_project.waste_collection_23_25_summary
WHERE TRIM(material) != '';

SELECT * FROM dataschool_project.waste_collection_23_25_summary 
WHERE TRIM(material) = ''; -- check waste stream type

-- General information
SELECT wc.material,wc.authority, wc.period_id, wc.period, SUM(wc.tonnes_by_material), al.population
FROM dataschool_project.waste_collection_23_25_summary wc
JOIN dataschool_project.authority_locations_lookup al
ON wc.authority_id = al.authority_id
WHERE TRIM(wc.material) != ''
GROUP BY wc.material,wc.authority, wc.period_id, wc.period, al.population;

SELECT wc.authority_id, wc.authority, wc.total_tonnes 
FROM dataschool_project.waste_collection_23_25_summary wc
JOIN dataschool_project.authority_locations_lookup al
ON wc.authority = al.authority_name;

SELECT count(wc.authority_id) 
FROM dataschool_project.waste_collection_23_25_summary wc
JOIN dataschool_project.authority_locations_lookup al
ON wc.authority_id = al.authority_id; -- 623755

SELECT count(wc.authority_id) 
FROM dataschool_project.waste_collection_23_25_summary wc
JOIN dataschool_project.authority_locations_lookup al
ON wc.authority = al.authority_convert; -- 601406


-- SUM of tonnes by material
SELECT 
	wc.material,
    al.authority_convert, 
    al.population, 
    wc.period, 
    ROUND(SUM(wc.tonnes_by_material), 2) as material_tonnes, 
    ROUND((al.population * 100)/@England_population, 2) as population_percentage
FROM dataschool_project.waste_collection_23_25_summary wc
JOIN dataschool_project.authority_locations_lookup al
ON wc.authority_id = al.authority_id
WHERE TRIM(wc.material) != ''
GROUP BY wc.material,al.authority_convert, al.population, wc.period
ORDER BY SUM(wc.tonnes_by_material) DESC;

-- char 13 is return character
SET @character13 = CHAR(13);
-- char 10 is line feed
SET @character10 = CHAR(10);
-- char 9 is tab
SET @character9 = CHAR(9);

-- This query shows what character contains in MaterialGroup
SELECT material, 
CASE
	WHEN material LIKE CONCAT('%', @character13, '%') THEN 'Return'
	WHEN material LIKE CONCAT('%', @character10, '%') THEN 'Line Feed'
	WHEN material LIKE CONCAT('%', @character9, '%') THEN 'Tab'
    ELSE 'Empty'
END  
FROM dataschool_project.waste_collection_23_25_summary
WHERE material LIKE CONCAT('%', @character13, '%') OR 
	material LIKE CONCAT('%', @character10, '%') OR 
	material LIKE CONCAT('%', @character9, '%'); 
    
SELECT count(distinct(wc.authority_id)) 
FROM dataschool_project.waste_collection_23_25_summary wc
JOIN dataschool_project.authority_locations_lookup al
ON wc.authority_id = al.authority_id;  -- 321

SELECT count(*) 
FROM dataschool_project.authority_locations_lookup al
JOIN dataschool_project.local_authority_districts_2025 la
ON al.authority_convert = la.lad25_name
where la.lad25_code LIKE 'E%';  -- 292

SELECT authority, tonnes_by_material, total_tonnes FROM dataschool_project.main_waste_collection_2025;

-- total tonnes per period
SELECT SUM(total_tonnes), SUM(tonnes_by_material), period_id FROM dataschool_project.main_waste_collection_2025
GROUP BY total_tonnes, tonnes_by_material, period_id;

-- total tonnest per population and material
SELECT SUM(total_tonnes), SUM(tonnes_by_material), period_id FROM dataschool_project.main_waste_collection_2025
GROUP BY total_tonnes, tonnes_by_material, period_id;

-- total tonnest when tonnes per material is zero
SELECT * FROM dataschool_project.main_waste_collection_2025
where output_process_type = 'Treatment unknown';

-- to differetiate total_tonnes and tonnes by material
SELECT SUM(total_tonnes), SUM(tonnes_by_material), material, authority FROM dataschool_project.main_waste_collection_2025
GROUP BY total_tonnes, tonnes_by_material, material, authority;



