with campus as (
    select st_unaryunion(st_collect(geog::geometry)) as geom
    from phl.penn_campus
)

select count(bg.geoid)::integer as count_block_groups
from census.blockgroups_2020 as bg
cross join campus as c
where st_coveredby(bg.geog::geometry, c.geom);
