select count(*)::integer as count_block_groups
from census.blockgroups_2020 as bg
where st_covers(
    (
        select geog
        from phl.neighborhoods
        where name = 'UNIVERSITY_CITY'
    ),
    bg.geog
)