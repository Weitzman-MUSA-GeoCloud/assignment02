/*
  Using the Philadelphia Water Department Stormwater Billing Parcels dataset,
  pair each parcel with its closest bus stop. The final result should give
  the parcel address, bus stop name, and distance apart in meters, rounded to
  two decimals. Order by distance (largest on top).

*/

SELECT
    p.address AS parcel_address,
    s.stop_name,
    ROUND(ST_DISTANCE(p.geog, s.geog)::numeric, 2) AS distance
FROM phl.pwd_parcels AS p
CROSS JOIN
    LATERAL (
        SELECT
            stops.stop_name,
            stops.geog
        FROM septa.bus_stops AS stops
        ORDER BY p.geog <-> stops.geog
        LIMIT 1
    ) AS s
ORDER BY distance DESC;
