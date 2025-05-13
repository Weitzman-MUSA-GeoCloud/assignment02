/*
With a query involving PWD parcels and census block groups,
 find the geo_id of the block group that contains Meyerson Hall.
 ST_MakePoint() and functions like that are not allowed.
*/

SELECT bg.geoid AS geo_id
FROM phl.pwd_parcels AS p
INNER JOIN census.blockgroups_2020 AS bg
    ON ST_WITHIN(p.geog::geometry, bg.geog::geometry)
WHERE p.address ILIKE '220-30 S 34TH ST'
LIMIT 1;
