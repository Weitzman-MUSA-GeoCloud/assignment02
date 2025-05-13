with phila_blockgroups as (
    select
        bg.geog,
        '1500000US' || bg.geoid as geoid
    from census.blockgroups_2020 as bg
    where bg.geoid like '42101%'
),

septa_bus_stop_blockgroups as (
    select
        s.stop_id,
        bg.geoid
    from septa.bus_stops as s
    inner join phila_blockgroups as bg
        on st_dwithin(s.geog, bg.geog, 800)
),

septa_bus_stop_surrounding_population as (
    select
        s.stop_id,
        sum(p.total) as estimated_pop_800m
    from septa_bus_stop_blockgroups as s
    inner join census.population_2020 as p
        using (geoid)
    group by s.stop_id
)

select
    bs.stop_name,
    pop.estimated_pop_800m,
    bs.geog
from septa_bus_stop_surrounding_population as pop
inner join septa.bus_stops as bs
    using (stop_id)
where pop.estimated_pop_800m > 500
order by pop.estimated_pop_800m
limit 8;