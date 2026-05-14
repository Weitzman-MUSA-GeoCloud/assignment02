/*
  What are the top five neighborhoods according to your accessibility metric?

  Accessibility Metric: Percentage of wheelchair accessible bus stops in each neighborhood.
*/

with neighborhood_accessibility as (
    select
        neighborhoods.name as neighborhood_name,
        sum(case when stops.wheelchair_boarding = 1 then 1 else 0 end)::integer as num_bus_stops_accessible,
        sum(case when stops.wheelchair_boarding != 1 or stops.wheelchair_boarding is null then 1 else 0 end)::integer as num_bus_stops_inaccessible,
        round(
            (
                sum(case when stops.wheelchair_boarding = 1 then 1 else 0 end)::numeric
                / nullif(count(stops.stop_id), 0)
            ) * 100, 2
        ) as accessibility_metric
    from phl.neighborhoods as neighborhoods
    left join septa.bus_stops as stops
        on st_contains(neighborhoods.geog::geometry, stops.geog::geometry)
    group by neighborhoods.name
)

select
    neighborhood_name,
    accessibility_metric,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
from neighborhood_accessibility
where accessibility_metric is not null
order by accessibility_metric desc
limit 5
