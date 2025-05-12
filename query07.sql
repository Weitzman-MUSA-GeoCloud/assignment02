/*
query focuses on areas identified as University City within the 2020 census block group data. 
It examines the spatial relationship between census block groups and the University City neighborhood.
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

