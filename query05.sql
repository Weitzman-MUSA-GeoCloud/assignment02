WITH accessible_stops AS (
  SELECT
    stop_id,
    stop_lat,
    stop_lon,
    ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326)::geography AS geog
  FROM septa.bus_stops
  WHERE wheelchair_boarding = 1
),

stops_with_neighborhoods AS (
  SELECT
    n.name AS neighborhood,
    n.geog AS neighborhood_geog,
    a.stop_id
  FROM phl.neighborhoods n
  JOIN accessible_stops a
  ON ST_Intersects(n.geog, a.geog)
),

counts AS (
  SELECT
    neighborhood,
    COUNT(*) AS accessible_stop_count,
    ST_Area(MAX(neighborhood_geog)) / 1000000.0 AS neighborhood_area_km2 
  FROM stops_with_neighborhoods
  GROUP BY neighborhood
)
SELECT
  neighborhood,
  accessible_stop_count,
  ROUND(neighborhood_area_km2, 2) AS area_km2,
  ROUND(accessible_stop_count / neighborhood_area_km2, 2) AS wheelchair_accessibility_score
FROM counts
ORDER BY wheelchair_accessibility_score DESC;

/*

Wheelchair Accessibility Score = (Number of wheelchair accessible stops) / (Area of the neighborhood in km²)

This creates a normalized stop density metric, allowing fair comparisons across neighborhoods of different sizes.
*/