SELECT
    p.parcel_address,
    s.stop_name,
    ROUND(
        ST_Distance(p.geog, s.geog)::numeric,
        2
    ) AS distance
FROM phl.pwd_parcels p
CROSS JOIN LATERAL (
    SELECT
        stop_name,
        geog
    FROM septa.bus_stops
    ORDER BY p.geog <-> geog
    LIMIT 1
) s
ORDER BY distance DESC;
