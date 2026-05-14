with university_city as (
    select n.geog
    from phl.neighborhoods as n
    where n.name = 'UNIVERSITY_CITY'
)

select count(*)::integer as count_block_groups
from census.blockgroups_2020 as bg
inner join university_city as uc
    on st_covers(uc.geog, bg.geog)
