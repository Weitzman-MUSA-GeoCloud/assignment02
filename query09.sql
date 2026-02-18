select bg.geoid as geo_id
from phl.pwd_parcels as parcels
inner join census.blockgroups_2020 as bg
    on st_covers(bg.geog, parcels.geog)
where parcels.address = '220-30 S 34TH ST'
limit 1