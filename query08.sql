/*
With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.
*/

set search_path = public;
WITH uc AS(
    SELECT listname,
    COUNT(bg.geoid) AS count_block_groups
    FROM phl.neighborhoods nb
    JOIN census.blockgroups_2020 bg
      ON ST_Within(bg.geog::geometry, nb.geog::geometry)
    WHERE listname = 'University City'
    GROUP BY listname
)
SELECT count_block_groups
FROM uc
ORDER BY count_block_groups DESC;

/*

Discussion:

Penn's main campus here was defined as the University City neighborhood as found in the phl.neighborhoods table.

*/