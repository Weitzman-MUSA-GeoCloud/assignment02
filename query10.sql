/*
  You're tasked with giving more contextual information to rail stops to fill the `stop_desc` field in a GTFS feed. Using any of the data sets above, PostGIS functions (e.g., `ST_Distance`, `ST_Azimuth`, etc.), and PostgreSQL string functions, build a description (alias as `stop_desc`) for each stop. Feel free to supplement with other datasets (must provide link to data used so it's reproducible), and other methods of describing the relationships. SQL's `CASE` statements may be helpful for some operations.
*/

with stop_parcels as (
    select
        s.stop_id,
        s.stop_name,
        s.stop_lon,
        s.stop_lat,
        p.address as parcel_address,
        st_distance(s.geog, p.geog) as dist,
        degrees(st_azimuth(st_centroid(p.geog::geometry), s.geog::geometry)) as azi
    from septa.rail_stops as s
    cross join lateral (
        select address, geog
        from phl.pwd_parcels
        order by s.geog <-> geog
        limit 1
    ) as p
)

select
    stop_id,
    stop_name,
    round(dist::numeric) || ' meters ' ||
    case
        when azi < 22.5 or azi >= 337.5 then 'N'
        when azi >= 22.5 and azi < 67.5 then 'NE'
        when azi >= 67.5 and azi < 112.5 then 'E'
        when azi >= 112.5 and azi < 157.5 then 'SE'
        when azi >= 157.5 and azi < 202.5 then 'S'
        when azi >= 202.5 and azi < 247.5 then 'SW'
        when azi >= 247.5 and azi < 292.5 then 'W'
        when azi >= 292.5 and azi < 337.5 then 'NW'
    end || ' of ' || parcel_address as stop_desc,
    stop_lon,
    stop_lat
from stop_parcels;
