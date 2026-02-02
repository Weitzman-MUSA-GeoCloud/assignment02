/*
 With a query involving PWD parcels and census block groups, find the geo_id of the block group that contains Meyerson Hall. ST_MakePoint() and functions like that are not allowed.

*/

with meyerson as (
    select geog
    from phl.pwd_parcels
    where address ilike '220-30 S 34th St'
)

select bg.geoid
from census.blockgroups_2020 as bg
inner join meyerson as m
    on st_contains(bg.geog::geometry, m.geog::geometry)
