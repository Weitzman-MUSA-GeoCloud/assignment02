/*
  Build a description (alias as stop_desc) for each rail stop using spatial
  relationships with nearby parcels and neighborhoods.

  The description includes:
  - Distance and direction to the nearest parcel
  - The neighborhood the stop is located in
*/

WITH nearest_parcel AS (
    SELECT
        stops.stop_id,
        parcels.address AS nearest_address,
        ST_DISTANCE(stops.geog, parcels.geog) AS dist,
        DEGREES(
            ST_AZIMUTH(
                stops.geog::geometry,
                ST_CENTROID(parcels.geog::geometry)
            )
        ) AS azimuth
    FROM septa.rail_stops AS stops
    CROSS JOIN LATERAL (
        SELECT
            pwd.address,
            pwd.geog
        FROM phl.pwd_parcels AS pwd
        ORDER BY ST_DISTANCE(stops.geog, pwd.geog)
        LIMIT 1
    ) AS parcels
),

stop_neighborhoods AS (
    SELECT
        stops.stop_id,
        neighborhoods.name AS neighborhood_name
    FROM septa.rail_stops AS stops
    LEFT JOIN phl.neighborhoods AS neighborhoods
        ON ST_CONTAINS(
            neighborhoods.geog::geometry,
            stops.geog::geometry
        )
)

SELECT
    stops.stop_id::integer AS stop_id,
    stops.stop_name,
    stops.stop_lon,
    stops.stop_lat,
    CONCAT(
        ROUND(np.dist::numeric, 0), ' meters ',
        CASE
            WHEN np.azimuth >= 337.5 OR np.azimuth < 22.5 THEN 'N'
            WHEN np.azimuth >= 22.5 AND np.azimuth < 67.5 THEN 'NE'
            WHEN np.azimuth >= 67.5 AND np.azimuth < 112.5 THEN 'E'
            WHEN np.azimuth >= 112.5 AND np.azimuth < 157.5 THEN 'SE'
            WHEN np.azimuth >= 157.5 AND np.azimuth < 202.5 THEN 'S'
            WHEN np.azimuth >= 202.5 AND np.azimuth < 247.5 THEN 'SW'
            WHEN np.azimuth >= 247.5 AND np.azimuth < 292.5 THEN 'W'
            WHEN np.azimuth >= 292.5 AND np.azimuth < 337.5 THEN 'NW'
        END,
        ' of ', np.nearest_address,
        COALESCE(' in ' || sn.neighborhood_name, '')
    ) AS stop_desc
FROM septa.rail_stops AS stops
LEFT JOIN nearest_parcel AS np
    ON stops.stop_id = np.stop_id
LEFT JOIN stop_neighborhoods AS sn
    ON stops.stop_id = sn.stop_id;
