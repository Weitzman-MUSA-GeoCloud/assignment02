SELECT
    rs.stop_id::integer AS stop_id,
    rs.stop_name,
    CONCAT(
        ROUND(
            ST_Distance(
                ST_SetSRID(ST_MakePoint(rs.stop_lon, rs.stop_lat), 4326)::geography,
                p.geog
            )::numeric,
            0
        ),
        ' meters from ',
        p.address
    ) AS stop_desc,
    rs.stop_lon,
    rs.stop_lat
FROM septa.bus_stops rs
CROSS JOIN LATERAL (
    SELECT p.*
    FROM phl.pwd_parcels p
    ORDER BY p.geog <-> ST_SetSRID(ST_MakePoint(rs.stop_lon, rs.stop_lat), 4326)::geography
    LIMIT 1
) p;