/*
Find out how many census block groups Penn's main campus fully contains.
Using the UNIVERSITY_CITY neighborhood as the definition of Penn's main campus.
*/

select count(*) as count_block_groups
from census.blockgroups_2020 cbg
where st_contains(
    (select geog::geometry from phl.neighborhoods where name = 'UNIVERSITY_CITY'),
    cbg.geog::geometry
)
