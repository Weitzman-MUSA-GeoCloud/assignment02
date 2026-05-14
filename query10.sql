/*
  Rate neighborhoods by their bus stop accessibility for wheelchairs. Use
  OpenDataPhilly's neighborhood dataset along with an appropriate dataset
  from the Septa GTFS bus feed. Use the [GTFS documentation]
  (https://gtfs.org/reference/static/) for help. Use some creativity in
  the metric you devise in rating neighborhoods.

*/

WITH rail_with_geog AS (
    SELECT
        stop_id,
        stop_name,
        stop_lon,
        stop_lat,
        ST_MakePoint(stop_lon, stop_lat)::geography AS geog
    FROM septa.rail_stops
),
nearest_info AS (
    SELECT
        r.stop_id,
        r.stop_name,
        r.stop_lon,
        r.stop_lat,
        p.address AS nearest_address,
        ROUND(ST_Distance(r.geog, p.geog)::numeric) AS dist_m,
        degrees(ST_Azimuth(
            r.geog::geometry,
            ST_Centroid(p.geog::geometry)
        )) AS azimuth_deg,
        n.name AS neighborhood_name
    FROM rail_with_geog AS r
    CROSS JOIN LATERAL (
        SELECT pwd.address, pwd.geog
        FROM phl.pwd_parcels AS pwd
        ORDER BY r.geog <-> pwd.geog
        LIMIT 1
    ) AS p
    LEFT JOIN phl.neighborhoods AS n
        ON ST_Covers(n.geog, r.geog)
)
SELECT
    stop_id,
    stop_name,
    dist_m || ' meters '
    || CASE
        WHEN azimuth_deg < 22.5 OR azimuth_deg >= 337.5 THEN 'N'
        WHEN azimuth_deg < 67.5 THEN 'NE'
        WHEN azimuth_deg < 112.5 THEN 'E'
        WHEN azimuth_deg < 157.5 THEN 'SE'
        WHEN azimuth_deg < 202.5 THEN 'S'
        WHEN azimuth_deg < 247.5 THEN 'SW'
        WHEN azimuth_deg < 292.5 THEN 'W'
        ELSE 'NW'
    END
    || ' of ' || nearest_address
    || COALESCE(' in ' || neighborhood_name, '')
    || ' - '
    || CASE
        WHEN dist_m < 30 THEN 'You’re almost there!'
        WHEN dist_m < 100 THEN 'A short stroll away'
        WHEN dist_m < 300 THEN 'Might want a coffee for this walk'
        ELSE 'Maybe grab a bottle of water for this trek'
    END
    AS stop_desc,
    stop_lon,
    stop_lat
FROM nearest_info
ORDER BY stop_id;
