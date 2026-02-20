/*
  With a query involving PWD parcels and census block groups, find the
  geo_id of the block group that contains Meyerson Hall. ST_MakePoint()
  and functions like that are not allowed.

  Structure (should be a single value):

  (
    geo_id text
  )
*/

select bg.geoid as geo_id
from
    census.blockgroups_2020 as bg
-- Join parcels to block groups where parcel is within block group.
inner join
    phl.pwd_parcels as parcels
    on st_contains(
        bg.geog::geometry,
        parcels.geog::geometry
    )
where
    -- Address for Meyerson Hall for filtering as typed in parcel data.
    parcels.address like '220-30 S 34TH ST';
