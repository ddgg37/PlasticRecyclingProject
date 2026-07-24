
-- #################### RANK COLUMN CALCULATION ##################################
-- In the end we cannot create this Ramk field as there are few Data problems

SELECT
    authority_id,
    recycled_tonnes,
    all_routes_tonnes,
    recycled_tonnes / all_routes_tonnes AS recycling_rate,
    recycling_rate_rank
FROM (
    SELECT
        al.authority_id,
        al.recycling_rate_rank,
        SUM(CASE WHEN wc.facility_type IN (
            'Reprocessor - recycling (qu19)', 'Exporter - recycling (qu19)',
            'Reuse (qu35)', 'Exporter - reuse (qu35)',
            'Windrow or other composting', 'In vessel composting',
            'Anaerobic or Aerobic Digestion Segregated'
        ) THEN wc.tonnes_by_material ELSE 0 END) AS recycled_tonnes,
        SUM(wc.tonnes_by_material) AS all_routes_tonnes
    FROM authority_locations_lookup al
    JOIN waste_collection_23_25_summary wc ON wc.authority_id = al.authority_id
    WHERE wc.facility_type <> 'Final Destination'
      AND wc.tonnes_by_material > 0
    GROUP BY al.authority_id, al.recycling_rate_rank
) x
WHERE recycling_rate_rank = 1
LIMIT 10;

UPDATE authority_locations_lookup al
JOIN (
    SELECT
        authority_id,
        RANK() OVER (ORDER BY recycled_tonnes / total_tonnes DESC) AS rnk
    FROM (
        SELECT
            authority_id,
            SUM(CASE WHEN facility_type IN (
                'Reprocessor - recycling (qu19)', 'Exporter - recycling (qu19)',
                'Reuse (qu35)', 'Exporter - reuse (qu35)',
                'Windrow or other composting', 'In vessel composting',
                'Anaerobic or Aerobic Digestion Segregated'
            ) THEN tonnes_by_material ELSE 0 END) AS recycled_tonnes,
            SUM(tonnes_by_material) AS total_tonnes
        FROM waste_collection_23_25_summary
        WHERE facility_type <> 'Final Destination'
          AND tonnes_by_material > 0
        GROUP BY authority_id
    ) rates
) ranked ON al.authority_id = ranked.authority_id
SET al.recycling_rate_rank = ranked.rnk;

ALTER TABLE authority_locations_lookup DROP COLUMN recycling_rate_rank;

-- ################################################################################


