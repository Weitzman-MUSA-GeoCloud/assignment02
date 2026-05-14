/*
  Build a descriptive stop_desc for each rail stop using PostGIS spatial functions.

  For each rail stop, find the nearest PWD parcel and describe the
  stop's direction and distance from that parcel address.

  Direction is derived from ST_Azimuth, converted to a compass bearing string.
*/

with rail_stop_geog as (
    select
        stop_id::integer as stop_id,
        stop_name,
        stop_lon,
        stop_lat,
        st_makepoint(stop_lon, stop_lat)::geography as geog
    from septa.rail_stops
),

nearest_parcel as (
    select
        r.stop_id,
        r.stop_name,
        r.stop_lon,
        r.stop_lat,
        r.geog as stop_geog,
        p.address as parcel_address,
        p.geog as parcel_geog
    from rail_stop_geog as r
    cross join lateral (
        select
            p.address,
            p.geog
        from phl.pwd_parcels as p
        order by r.geog <-> p.geog
        limit 1
    ) as p
),

stop_descriptions as (
    select
        stop_id,
        stop_name,
        stop_lon,
        stop_lat,
        round(st_distance(stop_geog, parcel_geog))
        || ' meters '
        || case
            when degrees(st_azimuth(
                st_centroid(parcel_geog::geometry),
                stop_geog::geometry
            )) < 22.5 then 'N'
            when degrees(st_azimuth(
                st_centroid(parcel_geog::geometry),
                stop_geog::geometry
            )) < 67.5 then 'NE'
            when degrees(st_azimuth(
                st_centroid(parcel_geog::geometry),
                stop_geog::geometry
            )) < 112.5 then 'E'
            when degrees(st_azimuth(
                st_centroid(parcel_geog::geometry),
                stop_geog::geometry
            )) < 157.5 then 'SE'
            when degrees(st_azimuth(
                st_centroid(parcel_geog::geometry),
                stop_geog::geometry
            )) < 202.5 then 'S'
            when degrees(st_azimuth(
                st_centroid(parcel_geog::geometry),
                stop_geog::geometry
            )) < 247.5 then 'SW'
            when degrees(st_azimuth(
                st_centroid(parcel_geog::geometry),
                stop_geog::geometry
            )) < 292.5 then 'W'
            when degrees(st_azimuth(
                st_centroid(parcel_geog::geometry),
                stop_geog::geometry
            )) < 337.5 then 'NW'
            else 'N'
        end
        || ' of ' || initcap(parcel_address) as stop_desc
    from nearest_parcel
)

select
    stop_id,
    stop_name,
    stop_desc,
    stop_lon,
    stop_lat
from stop_descriptions
order by stop_name
