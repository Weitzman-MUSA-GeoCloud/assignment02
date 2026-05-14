/*
  Bottom five neighborhoods by wheelchair bus stop accessibility metric.
*/

with stop_neighborhood as (
    select
        n.name as neighborhood_name,
        bs.wheelchair_boarding
    from phl.neighborhoods as n
    inner join septa.bus_stops as bs on st_intersects(n.geog, bs.geog)
),

neighborhood_stats as (
    select
        neighborhood_name,
        count(*) filter (where wheelchair_boarding = 1) as num_bus_stops_accessible,
        count(*) filter (where wheelchair_boarding = 2) as num_bus_stops_inaccessible,
        count(*) filter (where wheelchair_boarding in (1, 2)) as total_rated
    from stop_neighborhood
    group by neighborhood_name
)

select
    neighborhood_name,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible,
    round(
        num_bus_stops_accessible::numeric / nullif(total_rated, 0),
        4
    ) as accessibility_metric
from neighborhood_stats
where total_rated > 0
order by accessibility_metric asc
limit 5
