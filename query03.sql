/*
Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop.
The final result should give the parcel address, bus stop name, and distance apart in meters, rounded to two decimals.
Order by distance (largest on top).
*/

SELECT parcels.address AS parcel_address,
       stops.stop_name AS stop_name,
       ROUND(CAST(stops.dist AS numeric), 2) AS dist
FROM phl.pwd_parcels parcels
CROSS JOIN LATERAL (
  SELECT stops.stop_name, stops.geog, stops.stop_id, stops.geog <-> parcels.geog AS dist
  FROM septa.bus_stops AS stops
  ORDER BY dist
  LIMIT 1
) stops;