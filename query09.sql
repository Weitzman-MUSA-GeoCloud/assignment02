/*
  Find the geo_id of the block group that contains Meyerson Hall.
  Meyerson Hall is identified via PWD parcels (address containing "Meyerson"
  or similar). No ST_MakePoint() used.
*/

select bg.geoid as geo_id
from phl.pwd_parcels as p
inner join census.blockgroups_2020 as bg
    on public.st_contains(bg.geog::public.geometry, p.geog::public.geometry)
where (p.address ilike '%210%' and p.address ilike '%34th%')
   or p.address ilike '%meyer%'
limit 1
