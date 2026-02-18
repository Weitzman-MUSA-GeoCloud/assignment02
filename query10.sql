select
    stops.stop_id::integer as stop_id,
    stops.stop_name,
    round(st_distance(
        stops_geog,
        parcels.geog
    )::numeric) || ' meters '
    || case
        when degrees(st_azimuth(
            stops_geog::geometry,
            st_centroid(parcels.geog::geometry)
        )) between 337.5 and 360
        or degrees(st_azimuth(
            stops_geog::geometry,
            st_centroid(parcels.geog::geometry)
        )) between 0 and 22.5 then 'N'
        when degrees(st_azimuth(
            stops_geog::geometry,
            st_centroid(parcels.geog::geometry)
        )) between 22.5 and 67.5 then 'NE'
        when degrees(st_azimuth(
            stops_geog::geometry,
            st_centroid(parcels.geog::geometry)
        )) between 67.5 and 112.5 then 'E'
        when degrees(st_azimuth(
            stops_geog::geometry,
            st_centroid(parcels.geog::geometry)
        )) between 112.5 and 157.5 then 'SE'
        when degrees(st_azimuth(
            stops_geog::geometry,
            st_centroid(parcels.geog::geometry)
        )) between 157.5 and 202.5 then 'S'
        when degrees(st_azimuth(
            stops_geog::geometry,
            st_centroid(parcels.geog::geometry)
        )) between 202.5 and 247.5 then 'SW'
        when degrees(st_azimuth(
            stops_geog::geometry,
            st_centroid(parcels.geog::geometry)
        )) between 247.5 and 292.5 then 'W'
        else 'NW'
    end
    || ' of ' || parcels.address as stop_desc,
    stops.stop_lon,
    stops.stop_lat
from septa.rail_stops as stops
cross join lateral (
    select
        st_setsrid(
            st_makepoint(stops.stop_lon, stops.stop_lat), 4326
        )::geography as stops_geog
) as sg
cross join lateral (
    select
        p.address,
        p.geog
    from phl.pwd_parcels as p
    where p.address is not null
    order by sg.stops_geog <-> p.geog
    limit 1
) as parcels