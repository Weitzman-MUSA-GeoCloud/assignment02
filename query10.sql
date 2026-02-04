WITH stop_geog AS (
  SELECT
    stop_id,
    stop_name,
    stop_lon,
    stop_lat,
    ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326)::geography AS geog
  FROM septa.rail_stops
),
hood_centroids AS (
  SELECT
    name AS neighborhood_name,
    ST_Centroid(geog) AS center_geog
  FROM phl.neighborhoods
),
nearest_hood AS (
  SELECT
    s.stop_id,
    s.stop_name,
    s.stop_lon,
    s.stop_lat,
    h.neighborhood_name,
    ST_Distance(s.geog, h.center_geog) AS distance_m,
    ST_Azimuth(h.center_geog::geometry, s.geog::geometry) AS azimuth_rad
  FROM stop_geog s
  JOIN LATERAL (
    SELECT *
    FROM hood_centroids h
    ORDER BY s.geog <-> h.center_geog
    LIMIT 1
  ) h ON true
),
final_desc AS (
  SELECT
    stop_id,
    stop_name,
    stop_lon,
    stop_lat,
    ROUND(distance_m)::integer AS distance_m,
    neighborhood_name,
    CASE
      WHEN degrees(azimuth_rad) BETWEEN 22.5 AND 67.5 THEN 'NE'
      WHEN degrees(azimuth_rad) BETWEEN 67.5 AND 112.5 THEN 'E'
      WHEN degrees(azimuth_rad) BETWEEN 112.5 AND 157.5 THEN 'SE'
      WHEN degrees(azimuth_rad) BETWEEN 157.5 AND 202.5 THEN 'S'
      WHEN degrees(azimuth_rad) BETWEEN 202.5 AND 247.5 THEN 'SW'
      WHEN degrees(azimuth_rad) BETWEEN 247.5 AND 292.5 THEN 'W'
      WHEN degrees(azimuth_rad) BETWEEN 292.5 AND 337.5 THEN 'NW'
      ELSE 'N'
    END AS direction
  FROM nearest_hood
)
SELECT
  stop_id,
  stop_name,
  stop_lon,
  stop_lat,
  CONCAT(distance_m, ' meters ', direction, ' of ', neighborhood_name) AS stop_desc
FROM final_desc;
