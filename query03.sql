/*
  Using the Philadelphia Water Department Stormwater Billing Parcels dataset,
  pair each parcel with its closest bus stop. The final result should give the
  parcel address, bus stop name, and distance apart in meters, rounded to two
  decimals. Order by distance (largest on top).
*/

select
    p.address as parcel_address,
    trim(bs.stop_name) as stop_name,
    round(st_distance(p.geog, bs.geog)::numeric, 2) as distance
from phl.pwd_parcels as p
cross join
    lateral (
        select
            bus_stops.stop_name,
            bus_stops.geog
        from septa.bus_stops
        order by bus_stops.geog <-> p.geog
        limit 1
    ) as bs
order by distance desc
