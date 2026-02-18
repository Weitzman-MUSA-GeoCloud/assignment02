with bus_stops_accessible as (
    select
        stops.stop_id,
        stops.stop_name,
        stops.wheelchair_boarding,
        st_setsrid(
            st_makepoint(stops.stop_lon, stops.stop_lat), 4326
        )::geography as geog
    from septa.bus_stops as stops
),

neighborhood_stats as (
    select
        n.name as neighborhood_name,
        count(*) as total_stops,
        count(*) filter (
            where s.wheelchair_boarding = 1
        ) as num_bus_stops_accessible,
        count(*) filter (
            where s.wheelchair_boarding != 1 or s.wheelchair_boarding is null
        ) as num_bus_stops_inaccessible
    from phl.neighborhoods as n
    inner join bus_stops_accessible as s
        on st_covers(n.geog, s.geog)
    group by n.name
)

select
    neighborhood_name,
    round(
        num_bus_stops_accessible::numeric
        / nullif(total_stops, 0),
        2
    ) as accessibility_metric,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
from neighborhood_stats
order by accessibility_metric desc