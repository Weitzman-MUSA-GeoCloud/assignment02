/*
Generate descriptive information for rail stops using PostGIS functions.
Description format: "X meters [direction] of [nearest bus stop name]"
Direction is determined using ST_Azimuth function.
*/

select 
    rs.stop_id::integer,
    rs.stop_name,
    concat(
        round(st_distance(
            st_setsrid(st_point(rs.stop_lon, rs.stop_lat), 4326)::geography,
            st_setsrid(st_point(bs.stop_lon, bs.stop_lat), 4326)::geography
        )::numeric, 0), 
        ' meters ',
        case 
            when az >= 337.5 or az < 22.5 then 'N'
            when az >= 22.5 and az < 67.5 then 'NE'
            when az >= 67.5 and az < 112.5 then 'E'
            when az >= 112.5 and az < 157.5 then 'SE'
            when az >= 157.5 and az < 202.5 then 'S'
            when az >= 202.5 and az < 247.5 then 'SW'
            when az >= 247.5 and az < 292.5 then 'W'
            when az >= 292.5 and az < 337.5 then 'NW'
        end,
        ' of ',
        bs.stop_name
    ) as stop_desc,
    rs.stop_lon,
    rs.stop_lat
from septa.rail_stops rs
cross join lateral (
    select 
        stop_name,
        stop_lon,
        stop_lat,
        st_azimuth(
            st_setsrid(st_point(rs.stop_lon, rs.stop_lat), 4326)::geography,
            st_setsrid(st_point(stop_lon, stop_lat), 4326)::geography
        ) * 180.0 / pi() as az
    from septa.bus_stops
    order by st_setsrid(st_point(rs.stop_lon, rs.stop_lat), 4326)::geography <-> st_setsrid(st_point(stop_lon, stop_lat), 4326)::geography
    limit 1
) bs
order by rs.stop_id
