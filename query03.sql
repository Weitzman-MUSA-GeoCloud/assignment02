/*
Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel 
with its closest bus stop. The final result should give the parcel address, bus stop name,
and distance apart in meters, rounded to two decimals. Order by distance (largest on top).

*/

SELECT
    parcels.address,
    stops.stop_name,
    ROUND(ST_Distance(parcels.geog, stops.geog)::NUMERIC, 2) AS distance_meters
FROM phl.pwd_parcels AS parcels
JOIN LATERAL (
    SELECT
        bs.stop_name,
        ST_SetSRID(ST_MakePoint(bs.stop_lon, bs.stop_lat), 4326)::GEOGRAPHY AS geog
    FROM septa.bus_stops AS bs
    ORDER BY parcels.geog <-> ST_SetSRID(ST_MakePoint(bs.stop_lon, bs.stop_lat), 4326)::GEOGRAPHY
    LIMIT 1
) AS stops ON TRUE
ORDER BY distance_meters DESC;