/*
With a query, find out how many census block groups Penn's main campus fully contains.
Discuss which dataset you chose for defining Penn's campus.
*/
SELECT
    COUNT(bg.geoid) AS count_block_groups
FROM census.blockgroups_2020 AS bg
INNER JOIN phl.upenn AS penn
    ON st_within(penn.geog::geometry, bg.geog::geometry)