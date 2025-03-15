/*
With a query involving PWD parcels and census block groups, find the `geo_id` of the block group that contains Meyerson Hall.
`ST_MakePoint()` and functions like that are not allowed.
*/

--Find the parcel containing Meyerson Hall
--We know that the address is 210 South 34th Street, Philadelphia, PA 19104 and owned by University of Pennsylvania
select * 
from phl.pwd_parcels as parcels
WHERE parcels.address LIKE '%34TH%' AND parcels.owner1 LIKE '%UNIV%PENN%'
--The parcel ID is 265222

--Find geo_id of the block group
WITH
meyerson as
(select * 
from phl.pwd_parcels as parcels
WHERE parcels.parcelid=265222
)
select
	blocks.geoid AS geo_id
from meyerson
inner join census.blockgroups_2020 as blocks
	ON ST_Intersects(meyerson.geog, blocks.geog)
--The geo_id is 421010369022