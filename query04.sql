with shape_lines as (
    select
        shape_id,
        st_makeline(
            array_agg(
                st_setsrid(
                    st_makepoint(shape_pt_lon, shape_pt_lat),
                    4326
                )::geography::geometry
                order by shape_pt_sequence
            )
        )::geography as shape_geog
    from septa.bus_shapes
    group by shape_id
),

distinct_trips as (
    select distinct
        routes.route_short_name,
        trips.trip_headsign,
        trips.shape_id
    from septa.bus_trips as trips
    inner join septa.bus_routes as routes
        on trips.route_id = routes.route_id
),

ranked as (
    select
        dt.route_short_name,
        dt.trip_headsign,
        round(st_length(shapes.shape_geog)::numeric) as shape_length,
        row_number() over (
            order by st_length(shapes.shape_geog) desc
        ) as rn
    from distinct_trips as dt
    inner join shape_lines as shapes
        on dt.shape_id = shapes.shape_id
)

select
    route_short_name,
    trip_headsign,
    shape_length
from ranked
where rn <= 2