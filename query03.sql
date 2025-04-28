SET search_path TO public, septa, phl;

SELECT
    p.address AS parcel_address,
    stops.stop_name,
    ROUND(stops.dist::numeric, 2) AS distance
FROM phl.pwd_parcels AS p
CROSS JOIN
    LATERAL (
        SELECT
            s.stop_name,
            p.geog <-> s.geog AS dist
        FROM septa.bus_stops AS s
        ORDER BY dist
        LIMIT 1
    ) AS stops
ORDER BY distance DESC;
