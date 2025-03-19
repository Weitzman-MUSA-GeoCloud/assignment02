WITH penn_campus AS (
    -- Select the boundary of Penn’s main campus from the neighborhoods dataset
    SELECT geog::geometry AS campus_geom  -- Convert to geometry for ST_Contains()
    FROM phl.neighborhoods 
    WHERE name ILIKE '%university%' -- Ensure we select the University of Pennsylvania
)

SELECT COUNT(*) AS num_contained_block_groups
FROM census.blockgroups_2020 AS bg, penn_campus AS penn
WHERE ST_Contains(penn.campus_geom, bg.geog::geometry);
