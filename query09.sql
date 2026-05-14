/*
with
ucity as (
	select *
	from phl.neighborhoods
	where starts_with(listname, 'Uni')
)
select *
from phl.pwd_parcels as parcels
inner join ucity
on st_coveredby(parcels.geog, ucity.geog)
*/

-- used the above code to isolate ucity parcels
-- used pgadmin to visually find the meyerson parcel
-- used the address field value to select the necessary row in the following code
with
meyerson as (
    select *
    from phl.pwd_parcels
    where address = '220-30 S 34TH ST'
)

select block_grps.geoid
from census.blockgroups_2020 as block_grps
inner join meyerson
    on st_intersects(block_grps.geog, meyerson.geog);
