/* Rate neighborhoods by their bus stop accessibility for wheelchairs. Use OpenDataPhilly's neighborhood dataset along with an appropriate dataset from the Septa GTFS bus feed. Use the [GTFS documentation](https://gtfs.org/reference/static/) for help. Use some creativity in the metric you devise in rating neighborhoods.*/
CREATE INDEX IF NOT EXISTS neighborhoods_geog_gist
  ON phl.neighborhoods USING GIST (geog);

CREATE INDEX IF NOT EXISTS bus_stops_geog_gist
  ON septa.bus_stops USING GIST (geog);

CREATE INDEX IF NOT EXISTS bus_stops_wheelchair_idx
  ON septa.bus_stops (wheelchair_boarding);


WITH nbh AS (
  SELECT
    n.name,
    n.geog,
    ST_Area(n.geog) / 1000000.0 AS area_sqkm
  FROM phl.neighborhoods n
),
counts AS (
  SELECT
    n.name,
    COUNT(s.stop_id) AS total_stops,
    SUM(CASE WHEN s.wheelchair_boarding = 1 THEN 1 ELSE 0 END) AS accessible_stops,
    SUM(CASE WHEN s.wheelchair_boarding = 2 THEN 1 ELSE 0 END) AS not_accessible_stops,
    SUM(CASE WHEN s.wheelchair_boarding = 0 OR s.wheelchair_boarding IS NULL THEN 1 ELSE 0 END) AS unknown_stops
  FROM nbh n
  LEFT JOIN septa.bus_stops s
    ON ST_Covers(n.geog, s.geog)
  GROUP BY n.name
),
metrics AS (
  SELECT
    c.name,
    c.total_stops,
    c.accessible_stops,
    c.not_accessible_stops,
    c.unknown_stops,
    n.area_sqkm,
    CASE WHEN n.area_sqkm = 0 THEN 0
         ELSE c.accessible_stops::numeric / n.area_sqkm
    END AS density_per_sqkm,
    CASE WHEN c.total_stops = 0 THEN 0
         ELSE c.accessible_stops::numeric / c.total_stops
    END AS share_accessible
  FROM counts c
  JOIN nbh n USING (name)
)
SELECT
  name,
  total_stops,
  accessible_stops,
  ROUND(area_sqkm::numeric, 3) AS area_sqkm,
  ROUND(density_per_sqkm::numeric, 3) AS density_per_sqkm,
  ROUND(share_accessible::numeric, 3) AS share_accessible,
  ROUND((density_per_sqkm * share_accessible)::numeric, 3) AS score
FROM metrics
ORDER BY accessibility_metric DESC；
 