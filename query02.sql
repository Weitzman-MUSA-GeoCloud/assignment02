with septa_bus_stop_blockgroups as (
    select
        stops.stop_id,
        bg.geoid
    from septa.bus_stops as stops
    inner join census.blockgroups_2020 as bg
        on st_dwithin(stops.geog, bg.geog, 800)
    where bg.geoid like '42101%'
),

septa_bus_stop_surrounding_population as (
    select
        s.stop_id,
        sum(p.total) as estimated_pop_800m
    from septa_bus_stop_blockgroups s
    inner join census.population_2020 p
        on s.geoid = p.geoid
    group by s.stop_id
)

select
    stops.stop_id,
    stops.stop_name,
    pop.estimated_pop_800m
from septa_bus_stop_surrounding_population pop
inner join septa.bus_stops stops
    on pop.stop_id = stops.stop_id
where pop.estimated_pop_800m > 500
order by pop.estimated_pop_800m asc
limit 8;
