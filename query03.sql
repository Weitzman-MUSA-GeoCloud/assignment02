SELECT
    p.address AS parcel_address,
    nearest.stop_name,
    ROUND(ST_DISTANCE(p.geog, nearest.geog)::numeric, 2) AS distance
FROM phl.pwd_parcels AS p
CROSS JOIN
    LATERAL (
        SELECT
            s.stop_name,
            s.geog
        FROM septa.bus_stops AS s
        ORDER BY p.geog <-> s.geog
        LIMIT 1
    ) AS nearest
ORDER BY distance DESC;
