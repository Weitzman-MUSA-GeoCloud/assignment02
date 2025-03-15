/*
  You're tasked with giving more contextual information to rail stops to fill the stop_desc field in a GTFS feed. Using any of the data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string functions, build a description (alias as stop_desc) for each stop. Feel free to supplement with other datasets (must provide link to data used so it's reproducible), and other methods of describing the relationships. SQL's CASE statements may be helpful for some operations.
*/

with nearest_bus_stop as (
    select
        rs.stop_id as rail_stop_id,
        rs.stop_name as rail_stop_name,
        bs.stop_name as nearest_bus_stop,
        round(st_distance(st_setsrid(st_makepoint(rs.stop_lon, rs.stop_lat), 4326)::geography, bs.geog)::numeric, 2) as distance_m,
        st_azimuth(st_setsrid(st_makepoint(rs.stop_lon, rs.stop_lat), 4326)::geography, bs.geog) as azimuth
    from septa.rail_stops as rs
    left join lateral (
        select
            bus_stops.stop_name,
            bus_stops.geog
        from septa.bus_stops
        order by st_setsrid(st_makepoint(rs.stop_lon, rs.stop_lat), 4326)::geography <-> bus_stops.geog
        limit 1
    ) as bs on true
),

stop_descriptions as (
    select
        rail_stop_id,
        rail_stop_name,
        nearest_bus_stop,
        distance_m,
        case
            when azimuth between radians(337.5) and radians(22.5) then 'north'
            when azimuth between radians(22.5) and radians(67.5) then 'northeast'
            when azimuth between radians(67.5) and radians(112.5) then 'east'
            when azimuth between radians(112.5) and radians(157.5) then 'southeast'
            when azimuth between radians(157.5) and radians(202.5) then 'south'
            when azimuth between radians(202.5) and radians(247.5) then 'southwest'
            when azimuth between radians(247.5) and radians(292.5) then 'west'
            when azimuth between radians(292.5) and radians(337.5) then 'northwest'
            else 'unknown'
        end as direction
    from nearest_bus_stop
)

select
    rail_stop_id,
    rail_stop_name,
    'Nearest bus stop: ' || nearest_bus_stop || ', '
    || round(distance_m, 1) || 'm ' || direction || ' of the station.' as stop_desc
from stop_descriptions;
