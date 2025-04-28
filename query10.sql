WITH nearest_parcel AS (
    SELECT
        r.stop_id,
        r.stop_name,
        r.stop_lon,
        r.stop_lat,
        p.address,
        ST_DISTANCE(r.geog, p.geog) AS dist_meters,
        ST_AZIMUTH(r.geog::geometry, ST_CENTROID(p.geog::geometry)) AS azimuth_rad
    FROM septa.rail_stops AS r
    LEFT JOIN
        LATERAL (
            SELECT
                p.address,
                p.geog
            FROM phl.pwd_parcels AS p
            ORDER BY r.geog <-> p.geog
            LIMIT 1
        ) AS p ON true
)

SELECT
    stop_id,
    stop_name,
    stop_lon,
    stop_lat,
    CONCAT(
        ROUND(dist_meters)::text,
        ' meters ',
        CASE
            WHEN DEGREES(azimuth_rad) BETWEEN 0 AND 45 THEN 'N'
            WHEN DEGREES(azimuth_rad) BETWEEN 45 AND 135 THEN 'E'
            WHEN DEGREES(azimuth_rad) BETWEEN 135 AND 225 THEN 'S'
            WHEN DEGREES(azimuth_rad) BETWEEN 225 AND 315 THEN 'W'
            ELSE 'N'
        END,
        ' of ',
        address
    ) AS stop_desc
FROM nearest_parcel;
