/*
With a query, find out how many census block groups Penn's main
campus fully contains. Discuss which dataset you chose for
defining Penn's campus.
*/

WITH penn_campus AS (
    SELECT st_convexhull(st_union(geog::geometry)) AS geom
    FROM phl.pwd_parcels
    WHERE
        owner1 ILIKE '%univ%penn%'
        OR owner1 ILIKE '%univ of penn%'
)

SELECT count(*) AS count_block_groups
FROM census.blockgroups_2020 AS bg, penn_campus
WHERE st_contains(penn_campus.geom, bg.geog::geometry)
