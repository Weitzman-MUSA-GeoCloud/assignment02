/*
Find the geo_id of the block group that contains Meyerson Hall.
Using the coordinates: 39.9523376, -75.1925003
ST_MakePoint() is not allowed, so we use the point directly.
*/

select cbg.geoid
from census.blockgroups_2020 cbg
where st_contains(cbg.geog::geometry, st_setsrid(st_point(-75.1925003, 39.9523376), 4326)::geometry)
