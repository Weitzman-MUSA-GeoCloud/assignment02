/*
  What are the top five neighborhoods according to your accessibility metric?
*/

with neighborhood_stops as (
    select
        n.name as neighborhood_name,
        count(bs.stop_id) as total_stops,
        coalesce(sum(case when bs.wheelchair_boarding > 0 then 1 else 0 end), 0) as accessible_stops,
        coalesce(sum(bs.wheelchair_boarding), 0) as total_wheelchair_boarding
    from phl.neighborhoods as n
    inner join septa.bus_stops as bs
        on st_intersects(n.geog, bs.geog)
    group by n.name
),

neighborhood_area as (
    select
        name as neighborhood_name,
        st_area(geog::geography) / 1000000 as area_km2
    from phl.neighborhoods
),

stop_area_values as (
    select
        ns.neighborhood_name,
        ns.total_stops,
        ns.accessible_stops,
        ns.total_wheelchair_boarding,
        na.area_km2,
        (ns.total_stops::numeric / nullif(na.area_km2, 0)) as stop_area_ratio
    from neighborhood_stops as ns
    inner join neighborhood_area as na on ns.neighborhood_name = na.neighborhood_name
),

final_scores as (
    select
        sav.neighborhood_name,
        sav.total_stops,
        sav.accessible_stops,
        sav.total_wheelchair_boarding,
        sav.area_km2,
        sav.stop_area_ratio,
        (sav.accessible_stops::numeric / nullif(sav.total_stops, 0)) as accessible_stop_percentage,
        (sav.total_wheelchair_boarding::numeric / nullif(sav.accessible_stops, 0)) as avg_wheelchair_boarding,
        (
            sav.stop_area_ratio
            * (sav.accessible_stops::numeric / nullif(sav.total_stops, 0))
            * (sav.total_wheelchair_boarding::numeric / nullif(sav.accessible_stops, 0))
        ) as accessibility_metric
    from stop_area_values as sav
)

select
    neighborhood_name,
    accessible_stops,
    (total_stops - accessible_stops) as inaccessible_stops,
    round(accessibility_metric::numeric, 2) as accessibility_metric
from final_scores
order by accessibility_metric desc
limit 5;
