with
neighborhoods as (
    select
        n.name as neighborhood_name,
        n.geog as n_geog,
        st_transform(n.geog::geometry, 26918) as n_geom_utm
    from phl.neighborhoods as n
),

stops_in_neighborhood as (
    select
        nb.neighborhood_name,
        nb.n_geom_utm,
        s.stop_id,
        s.wheelchair_boarding,
        st_transform(s.geog::geometry, 26918) as stop_geom_utm
    from neighborhoods as nb
    inner join septa.bus_stops as s
        on st_intersects(nb.n_geog, s.geog)
),

stop_counts as (
    select
        neighborhood_name,
        count(*) filter (where wheelchair_boarding = 1) as num_bus_stops_accessible,
        count(*) filter (where wheelchair_boarding = 2) as num_bus_stops_inaccessible
    from stops_in_neighborhood
    group by neighborhood_name
),

accessible_buffer_union as (
    select
        neighborhood_name,
        n_geom_utm,
        st_unaryunion(st_collect(st_buffer(stop_geom_utm, 200))) as accessible_buffers_utm
    from stops_in_neighborhood
    where wheelchair_boarding = 1
    group by neighborhood_name, n_geom_utm
),

coverage as (
    select
        nb.neighborhood_name,
        coalesce(
            round(
                (
                    st_area(st_intersection(nb.n_geom_utm, abu.accessible_buffers_utm))
                    / nullif(st_area(nb.n_geom_utm), 0)
                )::numeric,
                2
            ),
            0.00
        ) as accessibility_metric
    from neighborhoods as nb
    left join accessible_buffer_union as abu
        on nb.neighborhood_name = abu.neighborhood_name
)

select
    c.neighborhood_name,
    c.accessibility_metric,
    coalesce(sc.num_bus_stops_accessible, 0) as num_bus_stops_accessible,
    coalesce(sc.num_bus_stops_inaccessible, 0) as num_bus_stops_inaccessible
from coverage as c
left join stop_counts as sc
    on c.neighborhood_name = sc.neighborhood_name
order by
    c.accessibility_metric desc,
    coalesce(sc.num_bus_stops_accessible, 0) desc
limit 5;
