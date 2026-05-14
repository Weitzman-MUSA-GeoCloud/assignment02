/*
Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, 
find the two routes with the longest trips.
Use ST_MakeLine to construct the geometry and calculate total trip length.
*/

select 
    route_short_name,
    trip_headsign,
    round(sum(trip_length)::numeric) as shape_length
from (
    select 
        br.route_short_name,
        bt.trip_headsign,
        st_length(st_makeline(array_agg(st_point(bs.shape_pt_lon, bs.shape_pt_lat) order by bs.shape_pt_sequence))) as trip_length
    from septa.bus_routes br
    join septa.bus_trips bt on br.route_id = bt.route_id
    join septa.bus_shapes bs on bt.shape_id = bs.shape_id
    group by br.route_id, br.route_short_name, bt.trip_id, bt.trip_headsign
) trip_lengths
group by route_short_name, trip_headsign
order by shape_length desc
limit 2
