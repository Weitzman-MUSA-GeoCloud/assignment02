with route_lengths as (
    select
        shape_id,
        st_length(
            st_makeline(
                array_agg(
                    st_setsrid(
                        st_makepoint(shape_pt_lon, shape_pt_lat), 4326
                    )
                    order by shape_pt_sequence
                )
            )::geography
        ) as shape_length
    from septa.bus_shapes
    group by shape_id
),

longest_routes as (
    select distinct on (rtes.route_id)
        rtes.route_id as route_short_name,
        trps.trip_headsign,
        rtln.shape_length
    from septa.bus_routes as rtes
    inner join septa.bus_trips as trps on rtes.route_id = trps.route_id
    inner join route_lengths as rtln on trps.shape_id = rtln.shape_id
    order by
        rtes.route_id asc,
        rtln.shape_length desc
)

select *
from longest_routes
order by shape_length desc;
