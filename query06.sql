select
    n.mapname as neighborhood_name,
    round(
        100.0
        * count(bs.stop_id) filter (where bs.wheelchair_boarding = 1)
        / nullif(count(bs.stop_id), 0),
        2
    ) as accessibility_metric,
    count(bs.stop_id) filter (where bs.wheelchair_boarding = 1)
        as num_bus_stops_accessible,
    count(bs.stop_id) filter (where bs.wheelchair_boarding = 2)
        as num_bus_stops_inaccessible
from phl.neighborhoods as n
left join septa.bus_stops as bs
    on st_covers(n.geog, bs.geog)
group by n.mapname
order by accessibility_metric desc nulls last
limit 5
