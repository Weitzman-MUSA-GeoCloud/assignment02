with shape_geoms as (
    select
        shape_id,
        st_makeline(
            geog::geometry
            order by shape_pt_sequence
        ) as length_geom
    from septa.bus_shapes
    group by shape_id
),

shape_lengths as (
    select
        shape_id,
        length_geom::geography as shape_geog,
        round(st_length(length_geom::geography)::numeric, 0) as shape_length
    from shape_geoms
),

trips_with_lengths as (
    select
        trips.route_id,
        trips.trip_headsign,
        trips.shape_id,
        shape_lengths.shape_length,
        shape_lengths.shape_geog
    from septa.bus_trips as trips
    left join shape_lengths using (shape_id)
),

routes_with_lengths as (
    select
        twl.route_id,
        twl.trip_headsign,
        twl.shape_geog,
        twl.shape_length,
        routes.route_short_name
    from trips_with_lengths as twl
    left join septa.bus_routes as routes using (route_id)
)

select
    route_short_name,
    trip_headsign,
    shape_geog,
    max(shape_length) as shape_length
from routes_with_lengths
group by route_short_name, trip_headsign, shape_geog
order by shape_length desc
limit 2;