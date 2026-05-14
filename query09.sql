select bg.geoid as geo_id
from census.blockgroups_2020 as bg
inner join phl.pwd_parcels as p
    on st_within(p.geog::geometry, bg.geog::geometry)
where
    upper(p.address) like '%34TH ST%'
    and upper(p.address) like '%210%'
order by bg.geoid
limit 1
