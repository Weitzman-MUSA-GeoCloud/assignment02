/*
  Using the Philadelphia Water Department Stormwater Billing Parcels dataset,
  pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name,
  and distance apart in meters, rounded to two decimals. Order by distance (largest on top).
*/

-- the closest bus stop for each parcel
SELECT
    parcels.address AS parcel_address,
    TRIM(BOTH ' ' FROM stops.stop_name) AS stop_name,
    ROUND(ST_DISTANCE(parcels.geog, stops.geog)::numeric, 2) AS distance
FROM phl.pwd_parcels AS parcels
INNER JOIN LATERAL (
    SELECT
        bus_stops.stop_name,
        bus_stops.geog
    FROM septa.bus_stops
    ORDER BY parcels.geog <-> septa.bus_stops.geog
    LIMIT 1
) AS stops ON true
ORDER BY distance DESC;
