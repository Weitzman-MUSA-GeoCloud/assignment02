SET search_path TO public, phl, septa, census;
WITH nearest_bus_stop AS (
    SELECT
        parcels.address AS parcel_address,
        stops.stop_name,
        ROUND(ST_Distance(parcels.geog, stops.geog)::numeric, 2) AS distance
    FROM
        phl.pwd_parcels AS parcels
    CROSS JOIN LATERAL (
        SELECT
            stop_name,
            geog
        FROM
            septa.bus_stops
        ORDER BY
            parcels.geog <-> geog
        LIMIT 1
    ) AS stops
)
SELECT
    parcel_address,
    stop_name,
    distance
FROM
    nearest_bus_stop
ORDER BY
    distance DESC;
