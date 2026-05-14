with

shape_geoms as (
    select
        shape_id,
        st_makeline(
            array_agg(
                st_makepoint(shape_pt_lon, shape_pt_lat)
                order by shape_pt_sequence
            )
        ) as shape_geom
    from septa.bus_shapes
    group by shape_id
),

trip_lengths as (
    select
        t.route_id,
        t.trip_headsign,
        round(st_length(sg.shape_geom::geography)) as shape_length
    from septa.bus_trips as t
    inner join shape_geoms as sg using (shape_id)
),

ranked_trips as (
    select
        route_id,
        trip_headsign,
        shape_length,
        row_number() over (
            partition by route_id
            order by shape_length desc
        ) as rn
    from trip_lengths
)

select
    r.route_short_name,
    t.trip_headsign,
    t.shape_length
from ranked_trips as t
inner join septa.bus_routes as r using (route_id)
where t.rn = 1
order by t.shape_length desc
limit 2
