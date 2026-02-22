with meyerson as (
    select p.geog::geometry as geom
    from phl.pwd_parcels as p
    where p.address = '220-30 S 34TH ST'
)

select bg.geoid as geo_id
from census.blockgroups_2020 as bg
inner join meyerson as m
    on st_covers(bg.geog::geometry, m.geom);
