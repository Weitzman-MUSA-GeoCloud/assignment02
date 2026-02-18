/*
Using the Philadelphia Water Department Stormwater Billing Parcels dataset, 
pair each parcel with its closest bus stop. Find the parcel address, bus stop name, 
and distance apart in meters, rounded to two decimals. 
Order by distance (largest on top).
This is a nearest neighbor problem.
*/

select 
    pp.address as parcel_address,
    bs.stop_name,
    round(st_distance(pp.geog, bs.geog)::numeric, 2) as distance
from phl.pwd_parcels pp
cross join lateral (
    select 
        stop_name,
        st_setsrid(st_point(stop_lon, stop_lat), 4326)::geography as geog
    from septa.bus_stops
    order by st_setsrid(st_point(stop_lon, stop_lat), 4326)::geography <-> pp.geog
    limit 1
) bs
order by distance desc
