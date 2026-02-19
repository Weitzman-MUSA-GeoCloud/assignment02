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
        -- Run subquery per parcel to find single closest bus stop.
        select
            septa.bus_stops.stop_name,
            -- Calculate actual geodesic distance in meters between parcel and bus stop,
            -- rounded to 2 decimal places.
            round(st_distance(phl.pwd_parcels.geog, septa.bus_stops.geog)::numeric, 2) as distance
        from septa.bus_stops
        -- Use <-> operator to pre-sort bus stops by approximate distance from current parcel
        -- using spatial index.
        order by phl.pwd_parcels.geog <-> septa.bus_stops.geog
        -- Keep only closest bus stop row.
        limit 1
    ) as nearest
-- Sort all parcels from farthest to nearest bus stop.
order by nearest.distance desc;
