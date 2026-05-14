/*
  With a query involving PWD parcels and census block groups, find the geo_id
  of the block group that contains Meyerson Hall. ST_MakePoint() and functions
  like that are not allowed.

  Meyerson Hall is located at 210 South 34th Street, Philadelphia. We find
  its parcel in the PWD dataset and then determine which census block group
  contains or intersects that parcel.
*/

select
    bg.geoid as geo_id
from census.blockgroups_2020 as bg
inner join phl.pwd_parcels as p
    on st_intersects(bg.geog, p.geog)
where p.address = '210 S 34TH ST'
