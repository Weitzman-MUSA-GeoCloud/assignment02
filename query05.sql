/*
  Rate neighborhoods by their bus stop accessibility for wheelchairs.
  
  Accessibility Metric: Percentage of wheelchair accessible bus stops in each neighborhood.
  
  According to GTFS documentation, wheelchair_boarding:
  - 0 or empty: No accessibility information
  - 1: Some vehicles at this stop can be boarded by a wheelchair user
  - 2: Wheelchair boarding is not possible at this stop
  
  The metric is calculated as:
  (number of accessible stops / total stops) * 100
  
  A higher percentage indicates better wheelchair accessibility.
*/

select
    neighborhoods.name as neighborhood_name,
    round(
        (sum(case when stops.wheelchair_boarding = 1 then 1 else 0 end)::numeric /
        nullif(count(stops.stop_id), 0)) * 100, 2
    ) as accessibility_metric,
    sum(case when stops.wheelchair_boarding = 1 then 1 else 0 end)::integer as num_bus_stops_accessible,
    sum(case when stops.wheelchair_boarding != 1 or stops.wheelchair_boarding is null then 1 else 0 end)::integer as num_bus_stops_inaccessible
from phl.neighborhoods as neighborhoods
left join septa.bus_stops as stops
    on st_contains(neighborhoods.geog::geometry, stops.geog::geometry)
group by neighborhoods.name
order by accessibility_metric desc nulls last
