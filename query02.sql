with philadelphia_blockgroups as (
    select
        geoid,
        geog
    from census.blockgroups_2020
    where geoid like '42101%'
)

select
    s.stop_id,
    s.stop_name,
    sum(p.total) as estimated_pop_800m
from septa.bus_stops as s
inner join philadelphia_blockgroups as bg
    on st_dwithin(s.geog, bg.geog, 800)
inner join census.population_2020 as p
    on p.geoid = '1500000US' || bg.geoid
group by
    s.stop_id,
    s.stop_name
having
    sum(p.total) > 500
order by
    estimated_pop_800m asc
limit 8;
