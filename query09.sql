/*
  Find the geo_id of the census block group that contains Meyerson Hall.
  Meyerson Hall address: 210 S 34th St, Philadelphia, PA 19104

  Instead of ST_MakePoint, we find Meyerson Hall by matching its address
  in the phl.pwd_parcels dataset and use that parcel's geometry.
*/

select bg.geoid as geo_id
from census.blockgroups_2020 as bg
inner join phl.pwd_parcels as p
    on st_within(p.geog::geometry, bg.geog::geometry)
where
    upper(p.address) like '%34TH ST%'
    and upper(p.address) like '%210%'
order by bg.geoid
limit 1
