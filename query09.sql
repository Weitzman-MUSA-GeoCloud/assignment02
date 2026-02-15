/*
9. With a query involving PWD parcels and census block groups, find the `geo_id` of the block group that contains Meyerson Hall. `ST_MakePoint()` and functions like that are not allowed.
*/

set search_path = public

SELECT geoid AS geo_id
FROM census.blockgroups_2020
WHERE ST_Covers(
    geog,
    'POINT(-75.1925955 39.9524158)'::geography
);
