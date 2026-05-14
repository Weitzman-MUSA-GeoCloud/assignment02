with stop_locations as (
    select
        stop_id::text as stop_id,
        stop_name,
        st_setsrid(
            st_makepoint(stop_lon, stop_lat), 4326
        )::geography as stop_geog
    from septa.bus_stops
)

select
    stops.stop_id,
    stops.stop_name,
    sum(pop.total)::integer as estimated_pop_800m
from stop_locations as stops
inner join census.blockgroups_2020 as bg
    on st_dwithin(
        bg.geog,
        stops.stop_geog,
        800
    )
inner join census.population_2020 as pop
    on bg.geoid = right(pop.geoid, 12)
where bg.geoid like '42101%'
group by stops.stop_id, stops.stop_name
having sum(pop.total) > 500
order by estimated_pop_800m asc, stops.stop_id asc
limit 8
