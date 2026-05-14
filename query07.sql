/*
  Bottom five neighborhoods by wheelchair accessibility metric.
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
order by accessibility_metric asc
limit 5
