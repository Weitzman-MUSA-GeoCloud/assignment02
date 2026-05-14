/* What are the _bottom five_ neighborhoods according to your accessibility metric? */ 



CREATE INDEX IF NOT EXISTS neighborhoods_geog_gist
  ON phl.neighborhoods USING GIST (geog);

CREATE INDEX IF NOT EXISTS bus_stops_geog_gist
  ON septa.bus_stops USING GIST (geog);

set search_path = public  

CREATE INDEX IF NOT EXISTS bus_stops_wheelchair_idx
  ON septa.bus_stops (wheelchair_boarding);

WITH neighborhood_area AS (
    SELECT
        n.name AS neighborhood_name,
        n.geog,
        ST_Area(n.geog) / 1000000.0 AS area_sqkm
    FROM phl.neighborhoods AS n
),
stops_joined AS (
    SELECT
        na.neighborhood_name,
        na.area_sqkm,
        s.stop_id,
        s.wheelchair_boarding
    FROM neighborhood_area AS na
    LEFT JOIN septa.bus_stops AS s
        ON ST_Covers(na.geog, s.geog)
),
counts AS (
    SELECT
        neighborhood_name,
        MAX(area_sqkm) AS area_sqkm,
        COUNT(stop_id) AS total_stops,
        SUM(CASE WHEN wheelchair_boarding = 1 THEN 1 ELSE 0 END) AS num_bus_stops_accessible,
        SUM(CASE WHEN wheelchair_boarding = 2 THEN 1 ELSE 0 END) AS num_bus_stops_inaccessible
    FROM stops_joined
    GROUP BY neighborhood_name
),
metrics AS (
    SELECT
        neighborhood_name,
        num_bus_stops_accessible,
        num_bus_stops_inaccessible,
        (num_bus_stops_accessible::numeric / NULLIF(total_stops, 0)) AS share_accessible,
        (num_bus_stops_accessible::numeric / NULLIF(area_sqkm, 0)) AS density_accessible
    FROM counts
)
SELECT
    neighborhood_name,
    ROUND((share_accessible * density_accessible)::numeric, 3) AS accessibility_metric,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
FROM metrics
ORDER BY accessibility_metric ASC
limit 5;
