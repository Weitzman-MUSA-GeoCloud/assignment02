/*
  Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters, rounded to two decimals. Order by distance (largest on top).
*/

select
    p.address as parcel_address,
    s.stop_name,
    round(cast(st_distance(p.geog, s.geog) as numeric), 2) as distance
from phl.pwd_parcels as p
cross join lateral (
    select stop_name, geog
    from septa.bus_stops
    order by p.geog <-> geog
    limit 1
) as s
order by distance desc;
