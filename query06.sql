/*
  What are the _top five_ neighborhoods according to your accessibility metric?
*/

select
    n.name as neighborhood_name,
    sum(case when s.wheelchair_boarding = 1 then 1 else 0 end) / (st_area(n.geog) / 1000000) as accessibility_metric,
    sum(case when s.wheelchair_boarding = 1 then 1 else 0 end) as num_bus_stops_accessible,
    sum(case when s.wheelchair_boarding = 2 then 1 else 0 end) as num_bus_stops_inaccessible
from phl.neighborhoods as n
left join septa.bus_stops as s
    on st_covers(n.geog, s.geog)
group by n.name, n.geog
order by accessibility_metric desc
limit 5;
