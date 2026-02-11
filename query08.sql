/*
  With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.
*/

with penns_campus as (
    select geog
    from phl.neighborhoods
    where name = 'UNIVERSITY_CITY'
)

select count(*) as count_block_groups
from census.blockgroups_2020 as bg
join penns_campus as c
on st_covers(c.geog, bg.geog);
