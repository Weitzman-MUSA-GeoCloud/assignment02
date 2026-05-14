/*
  Find the geo_id of the block group that contains Meyerson Hall.
  ST_MakePoint and similar functions are not allowed.

  Approach: Meyerson Hall (Weitzman School of Design) sits within the Penn-owned
  parcel at "220-60 S 33RD ST" in phl.pwd_parcels. We use ST_Within to find
  the census block group whose geometry contains the centroid of that parcel.
*/

select bg.geoid
from phl.pwd_parcels as p
inner join census.blockgroups_2020 as bg
    on st_within(st_centroid(p.geog::geometry), bg.geog::geometry)
where p.address = '220-60 S 33RD ST'
