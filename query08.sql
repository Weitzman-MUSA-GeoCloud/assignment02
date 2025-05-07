WITH university_city AS (
    SELECT geog 
    FROM phl.neighborhoods
    WHERE name = 'UNIVERSITY_CITY'
    LIMIT 1
)
SELECT 
    COUNT(*) AS count_block_groups
FROM 
    census.blockgroups_2020 bg
JOIN
    university_city uc
    ON ST_Within(bg.geog::geometry, uc.geog::geometry);
