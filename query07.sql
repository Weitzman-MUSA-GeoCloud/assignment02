
WITH neighborhoods_with_area AS (
  SELECT
    name AS neighborhood_name,
    geog,
    ST_Area(geog) / 1000000.0 AS area_km2  -- convert from m² to km²
  FROM phl.neighborhoods
),
bus_stops_with_geog AS (
  SELECT
    stop_name,
    wheelchair_boarding,
    ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326)::geography AS geog
  FROM septa.bus_stops
),
stops_in_neighborhoods AS (
  SELECT
    n.neighborhood_name,
    n.area_km2,
    b.wheelchair_boarding
  FROM neighborhoods_with_area n
  JOIN bus_stops_with_geog b
    ON ST_Contains(n.geog, b.geog)
),
aggregated AS (
  SELECT
    neighborhood_name,
    area_km2,
    COUNT(*) FILTER (WHERE wheelchair_boarding = 1) AS num_bus_stops_accessible,
    COUNT(*) FILTER (WHERE wheelchair_boarding != 1) AS num_bus_stops_inaccessible
  FROM stops_in_neighborhoods
  GROUP BY neighborhood_name, area_km2
),
with_metric AS (
  SELECT
    neighborhood_name,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible,
    ROUND(num_bus_stops_accessible / NULLIF(area_km2, 0), 2) AS accessibility_metric
  FROM aggregated
)
SELECT *
FROM with_metric
ORDER BY accessibility_metric ASC
LIMIT 5;