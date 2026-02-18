/*
  Build stop_desc for each rail stop using nearest PWD parcel (distance,
  direction, address). No supplemental datasets beyond assignment.
*/

with

rail_with_nearest as (
    select
        r.stop_id,
        r.stop_name,
        r.stop_lon,
        r.stop_lat,
        p.address as nearest_address,
        public.st_distance(r.geog, p.geog) as dist_m,
        public.st_azimuth(
            public.st_makepoint(r.stop_lon, r.stop_lat)::public.geography,
            public.st_centroid(p.geog::public.geometry)::public.geography
        ) as azimuth_rad
    from septa.rail_stops as r
    cross join lateral (
        select p.address, p.geog
        from phl.pwd_parcels as p
        where p.address is not null and p.address <> ''
        order by public.st_distance(r.geog, p.geog)
        limit 1
    ) as p
),

direction_label as (
    select
        stop_id,
        stop_name,
        stop_lon,
        stop_lat,
        nearest_address,
        round(dist_m)::integer as dist_m,
        case
            when azimuth_rad is null then 'N'
            when degrees(azimuth_rad) < 22.5 then 'N'
            when degrees(azimuth_rad) < 67.5 then 'NE'
            when degrees(azimuth_rad) < 112.5 then 'E'
            when degrees(azimuth_rad) < 157.5 then 'SE'
            when degrees(azimuth_rad) < 202.5 then 'S'
            when degrees(azimuth_rad) < 247.5 then 'SW'
            when degrees(azimuth_rad) < 292.5 then 'W'
            when degrees(azimuth_rad) < 337.5 then 'NW'
            else 'N'
        end as dir
    from rail_with_nearest
)
select
    stop_id::integer as stop_id,
    stop_name,
    (dist_m || ' meters ' || dir || ' of ' || coalesce(trim(nearest_address), 'unknown')) as stop_desc,
    stop_lon,
    stop_lat
from direction_label;
