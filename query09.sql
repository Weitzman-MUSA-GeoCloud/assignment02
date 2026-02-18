/*
  With a query involving PWD parcels and census block groups, find the `geo_id` of the block group that contains Meyerson Hall. `ST_MakePoint()` and functions like that are not allowed.
*/

select bg.geoid
from phl.pwd_parcels as p
join census.blockgroups_2020 as bg
on st_intersects(bg.geog, p.geog)
where p.address = '220-30 S 34TH ST';
