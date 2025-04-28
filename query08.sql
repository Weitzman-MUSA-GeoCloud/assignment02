WITH penn_campus AS (
    SELECT geog
    FROM phl.neighborhoods
    WHERE mapname ILIKE '%University City%'
)

SELECT COUNT(*) AS count_block_groups
FROM census.blockgroups_2020 AS bg,
    penn_campus
WHERE ST_CONTAINS(
    penn_campus.geog::geometry,
    bg.geog::geometry
);
