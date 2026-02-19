/*
  Using the Philadelphia Water Department Stormwater Billing Parcels
  dataset, pair each parcel with its closest bus stop. The final
  result should give the parcel address, bus stop name, and distance
  apart in meters, rounded to two decimals. Order by distance (largest
  on top).

  Your query should run in under two minutes.

  _HINT: This is a nearest neighbor problem.

  Structure:

  (
    parcel_address text,  -- The address of the parcel
    stop_name text,  -- The name of the bus stop
    distance numeric  -- The distance apart in meters, rounded to two decimals
  )
*/

select
    pwd_parcels.address as parcel_address,
    nearest.stop_name,
    nearest.distance
from phl.pwd_parcels
cross join
    lateral (
        select
            septa.bus_stops.stop_name,
            round(st_distance(phl.pwd_parcels.geog, septa.bus_stops.geog)::numeric, 2) as distance
        from septa.bus_stops
        order by phl.pwd_parcels.geog <-> septa.bus_stops.geog
        limit 1
    ) as nearest
order by nearest.distance desc;
