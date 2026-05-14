/*
With a query involving PWD parcels and census block groups, find the geo_id of the block group that contains Meyerson Hall. ST_MakePoint() and functions like that are not allowed.
*/

/*
Meyerson Parcel: address = 220-30 S 34TH ST
*/

set search_path = public;

SELECT bg.geoid as geo_id
FROM phl.pwd_parcels pa
JOIN census.blockgroups_2020 bg
  ON st_within(pa.geog::geometry, bg.geog::geometry)
WHERE pa.address = '220-30 S 34TH ST';