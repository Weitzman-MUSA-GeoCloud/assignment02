/*
With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.
*/

WITH university_city AS (
    SELECT geog
    FROM phl.neighborhoods
    WHERE listname = 'University City'
)
SELECT count(*) AS count_block_groups
FROM census.blockgroups_2020 AS bg
INNER JOIN university_city ON (
    public.st_within(bg.geog::public.geometry, university_city.geog::public.geometry)
);

