with meyerson as (
    select
        objectid,
        geog
    from phl.pwd_parcels
    where address ilike '220-30 s 34th st'
)

select bg.geoid
from census.blockgroups_2020 as bg
inner join meyerson
    on st_intersects(bg.geog, meyerson.geog);
