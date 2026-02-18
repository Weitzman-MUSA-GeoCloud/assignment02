select
    stops.stop_id::text as stop_id,
    stops.stop_name,
    sum(pop.total)::integer as estimated_pop_800m
from septa.bus_stops as stops
inner join census.blockgroups_2020 as bg
    on st_dwithin(
        bg.geog,
        st_setsrid(st_makepoint(stops.stop_lon, stops.stop_lat), 4326)::geography,
        800
    )
inner join census.population_2020 as pop
    on bg.geoid = pop.geoid
where bg.geoid like '42101%'
group by stops.stop_id, stops.stop_name
having sum(pop.total) > 500
order by estimated_pop_800m asc
limit 8