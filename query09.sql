/*
With a query involving PWD parcels and census block groups,
find the `geo_id` of the block group that contains Meyerson Hall.
`ST_MakePoint()` and functions like that are not allowed.
*/
WITH meyerson_parcel AS (
    SELECT
        pwd.geog
    FROM phl.pwd_parcels AS pwd
    WHERE pwd.address = '220-30 S 34TH ST'
)
SELECT
    bg.geoid AS geo_id
FROM census.blockgroups_2020 AS bg
INNER JOIN meyerson_parcel AS mey
    ON st_within(mey.geog::geometry, bg.geog::geometry)