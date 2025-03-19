with ucity as (
    select geog
    from phl.neighborhoods
    where listname = 'University City'
)

select count(*) as count_block_groups
from census.blockgroups_2020 as bg
inner join ucity on (st_within(bg.geog::geometry, ucity.geog::geometry));
