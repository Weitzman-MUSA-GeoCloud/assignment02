/*
Rate neighborhoods by their bus stop accessibility for wheelchairs.
Top 5 neighborhoods with highest accessibility metric.
Accessibility metric = (num_accessible_stops / total_stops) * 100
where wheelchair_boarding = 1 means accessible, 0 or 2 means not accessible
*/

select 
    neighborhood_name,
    round((cast(num_bus_stops_accessible as float) / nullif(num_bus_stops_accessible + num_bus_stops_inaccessible, 0) * 100)::numeric, 2) as accessibility_metric,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
from (
    select 
        pn.name as neighborhood_name,
        count(case when bs.wheelchair_boarding = 1 then 1 end) as num_bus_stops_accessible,
        count(case when bs.wheelchair_boarding in (0, 2) then 1 end) as num_bus_stops_inaccessible
    from phl.neighborhoods pn
    left join septa.bus_stops bs on st_intersects(pn.geog::geometry, st_setsrid(st_point(bs.stop_lon, bs.stop_lat), 4326))
    group by pn.name
    having count(bs.stop_id) > 0
) accessibility_scores
order by accessibility_metric desc
limit 5
