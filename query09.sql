/*
With a query involving PWD parcels and census block groups,
find the geo_id of the block group that contains Meyerson Hall.
ST_MakePoint() and functions like that are not allowed.
*/

SELECT bg.geoid AS geo_id
FROM census.blockgroups_2020 AS bg
INNER JOIN phl.pwd_parcels AS parcels
    ON st_contains(bg.geog::geometry, parcels.geog::geometry)
WHERE parcels.address = '220-30 S 34TH ST'
