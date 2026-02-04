

SET search_path TO public, phl, septa, census;
with septa_bus_stop_blockgroups as (
    select
        stops.stop_id,
        stops.stop_name,
        stops.stop_lat,
        stops.stop_lon,
        '1500000US' || bg.geoid as geoid
    from septa.bus_stops as stops
    inner join census.blockgroups_2020 as bg
        on ST_DWithin(
            ST_SetSRID(ST_MakePoint(stops.stop_lon, stops.stop_lat), 4326)::geography,
            bg.geog,
            800
        )
),
septa_bus_stop_surrounding_popn as (
    select
        stop_id,
        stop_name,
        stop_lat,
        stop_lon,
        sum(pop.total) as estimated_pop_800m
    from septa_bus_stop_blockgroups
    inner join census.population_2020 as pop using (geoid)
    group by stop_id, stop_name, stop_lat, stop_lon
)
select
    stop_name,
    estimated_pop_800m,
    ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326)::geography as geog
from septa_bus_stop_surrounding_popn
order by estimated_pop_800m desc
limit 1;
