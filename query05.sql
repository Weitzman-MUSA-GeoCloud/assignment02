/*
  Rate neighborhoods by their bus stop accessibility for wheelchairs.

  Metric: accessibility_metric = num_bus_stops_accessible / total_bus_stops (ratio)
  where wheelchair_boarding = 1 means accessible, 2 means not accessible, 0 means unknown.
  We count stops with wheelchair_boarding = 1 as accessible.
  Stops with wheelchair_boarding = 2 are inaccessible.
  Stops with wheelchair_boarding = 0 are treated as neither (excluded from ratio denominator).

  Final metric is the ratio of accessible stops to (accessible + inaccessible) stops.
  Neighborhoods with no stops are excluded.
*/

select
    n.name as neighborhood_name,
    sum(case when s.wheelchair_boarding = 1 then 1 else 0 end)::integer as num_bus_stops_accessible,
    sum(case when s.wheelchair_boarding = 2 then 1 else 0 end)::integer as num_bus_stops_inaccessible,
    round(
        sum(case when s.wheelchair_boarding = 1 then 1 else 0 end)::numeric
        / nullif(
            sum(case when s.wheelchair_boarding in (1, 2) then 1 else 0 end),
            0
        ),
        4
    ) as accessibility_metric
from phl.neighborhoods as n
inner join septa.bus_stops as s
    on st_within(s.geog::geometry, n.geog::geometry)
group by n.name
having sum(case when s.wheelchair_boarding in (1, 2) then 1 else 0 end) > 0
order by accessibility_metric desc
