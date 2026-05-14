/*
  Rate neighborhoods by their bus stop accessibility for wheelchairs. The
  accessibility metric is the proportion of bus stops in the neighborhood that
  are explicitly wheelchair accessible (wheelchair_boarding = 1) out of all
  bus stops in the neighborhood.

  GTFS wheelchair_boarding values:
    0 = No information available
    1 = At least some vehicles can be boarded by a rider in a wheelchair
    2 = Wheelchair boarding not possible
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
