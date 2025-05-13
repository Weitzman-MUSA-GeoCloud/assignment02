/*
With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.
*/
WITH
parcels as
(select * 
from phl.pwd_parcels as parcels
WHERE parcels.owner1 LIKE '%UNIV%PENN%'
UNION ALL
select * 
from phl.pwd_parcels as parcels
WHERE parcels.owner2 LIKE '%UNIV%PENN%')
select
	COUNT(DISTINCT blocks.blkgrpce) AS count_block_groups
from parcels
inner join census.blockgroups_2020 as blocks
	ON ST_Intersects(parcels.geog, blocks.geog)

--Discussion
--I chose the PWD parcels dataset to define Penn's campus.
--I used the owner1 and owner2 columns to filter out parcels that are owned by the University of Pennsylvania.
--I then used the ST_Intersects function to find the census block groups that intersect with these parcels.
--The count of distinct block groups gives the number of block groups that Penn's main campus fully contains.