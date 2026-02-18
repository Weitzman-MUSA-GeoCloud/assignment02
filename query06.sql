/*
  Top five neighborhoods by bus stop wheelchair accessibility metric.
*/

with

neighborhood_stops as (
    select
        n.listname as neighborhood_name,
        s.wheelchair_boarding,
        count(*) as stop_count
    from phl.neighborhoods as n
    inner join septa.bus_stops as s
        on public.st_contains(n.geog::public.geometry, s.geog::public.geometry)
    group by n.listname, s.wheelchair_boarding
),

neighborhood_totals as (
    select
        neighborhood_name,
        coalesce(sum(case when wheelchair_boarding = 1 then stop_count else 0 end), 0)::integer as num_bus_stops_accessible,
        coalesce(sum(case when wheelchair_boarding is distinct from 1 then stop_count else 0 end), 0)::integer as num_bus_stops_inaccessible
    from neighborhood_stops
    group by neighborhood_name
),

with_metric as (
    select
        neighborhood_name,
        case
            when (num_bus_stops_accessible + num_bus_stops_inaccessible) = 0 then 0
            else round(
                (num_bus_stops_accessible::numeric / (num_bus_stops_accessible + num_bus_stops_inaccessible)) * 100,
                2
            )
        end as accessibility_metric,
        num_bus_stops_accessible,
        num_bus_stops_inaccessible
    from neighborhood_totals
)
select
    neighborhood_name,
    accessibility_metric,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
from with_metric
where (num_bus_stops_accessible + num_bus_stops_inaccessible) > 0
order by accessibility_metric desc, neighborhood_name
limit 5
