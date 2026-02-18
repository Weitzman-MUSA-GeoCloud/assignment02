/*
  With a query involving PWD parcels and census block groups, find the geo_id of
  the block group that contains Meyerson Hall. ST_MakePoint() and functions like
  that are not allowed.
  
  Meyerson Hall is located at 210 S 34th St, Philadelphia, PA 19104.
  We'll find the parcel that matches this address and then find the block group
  that contains it.
*/

select bg.geoid as geo_id
from phl.pwd_parcels as parcels
inner join census.blockgroups_2020 as bg
    on st_intersects(bg.geog, parcels.geog)
where parcels.address like '%210 S 34%'
   or parcels.address like '%220 S 34%'
   or (parcels.address like '%34TH%' and parcels.owner1 like '%UNIV%PENN%')
limit 1
