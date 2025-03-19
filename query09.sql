with meyerson_parcel as (
    select geog
    from phl.pwd_parcels
    where address = '220-30 S 34TH ST'
)

select bg.geoid as geo_id
from census.blockgroups_2020 as bg
inner join meyerson_parcel as mey on st_dwithin(bg.geog, mey.geog, 5);
