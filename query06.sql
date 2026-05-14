/*
  What are the top five neighborhoods according to the wheelchair accessibility
  metric (proportion of bus stops that are wheelchair accessible)?
*/

with

neighborhood_stops as (
    select
        n.mapname as neighborhood_name,
        count(*) filter (where s.wheelchair_boarding = 1) as num_bus_stops_accessible,
        count(*) filter (where s.wheelchair_boarding != 1) as num_bus_stops_inaccessible,
        count(*) as total_stops
    from phl.neighborhoods as n
    inner join septa.bus_stops as s
        on st_within(s.geog::geometry, n.geog::geometry)
    group by n.mapname
)

select
    neighborhood_name,
    round(
        num_bus_stops_accessible::numeric / nullif(total_stops, 0),
        4
    ) as accessibility_metric,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
from neighborhood_stops
order by accessibility_metric desc, neighborhood_name
limit 5
