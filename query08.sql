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

/*
This query looks mainly at areas defined as
University city within the 2020 census
block group data
*/
