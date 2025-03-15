/*
  Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters, rounded to two decimals. Order by distance (largest on top).
*/

select
    p.address,
    s.stop_name,
    round(st_distance(p.geog, s.geog)::numeric, 2) as distance
from phl.pwd_parcels as p
inner join lateral (
    select
        bus_stops.stop_name,
        bus_stops.geog
    from septa.bus_stops
    order by p.geog <-> septa.bus_stops.geog
    limit 1
) as s on true
order by distance desc;
