/*
  Which bus stop has the largest population within 800 meters? As a rough
  estimation, consider any block group that intersects the buffer as being part
  of the 800 meter buffer.
*/


with stops as (
    select
        n.name as neighborhood_name,
        count(s.stop_id) as total_stops,
        coalesce(sum(case when s.wheelchair_boarding > 0 then 1 else 0 end), 0) as accessible_stops,
        coalesce(sum(s.wheelchair_boarding), 0) as total_wheelchair_boarding

    from phl.neighborhoods as n
    inner join septa.bus_stops as s
        on st_intersects(n.geog, s.geog)
    group by n.name
),

area as (
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
        (ns.accessible_stops)::numeric / nullif(na.area_km2, 0) as stop_area_ratio
    from stops as ns
    inner join area as na on ns.neighborhood_name = na.neighborhood_name
),

agg as (
    select
        sav.neighborhood_name,
        sav.accessible_stops,
        sav.stop_area_ratio,
        (sav.accessible_stops)::float / nullif(sav.total_stops, 0) as acc_ratio
    from stop_area_values as sav
),

z_score_data as (
    select
        *,
        -- Compute Z-score for total_stops
        (acc_ratio::float - avg(acc_ratio) over ())
        / nullif(stddev(acc_ratio) over (), 0) as acc_ratio_zscore,

        -- Compute Z-score for accessible_stops
        (accessible_stops::float - avg(accessible_stops) over ())
        / nullif(stddev(accessible_stops) over (), 0) as accessible_stops_zscore,

        -- Compute Z-score for total_wheelchair_boarding
        (stop_area_ratio::float - avg(stop_area_ratio) over ())
        / nullif(stddev(stop_area_ratio) over (), 0) as stop_area_ratio_zscore
    from agg
)

select
    neighborhood_name,
    (acc_ratio_zscore + accessible_stops_zscore + stop_area_ratio_zscore) / 3 as accessibility_metric
from z_score_data
order by accessibility_metric asc
limit 5
