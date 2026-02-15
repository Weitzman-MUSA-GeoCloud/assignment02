/*
6.  What are the _top five_ neighborhoods according to your accessibility metric?
*/
set search_path = public

WITH neighborhood_area AS (
    SELECT
        n.name AS neighborhood_name,
        n.geog,
        (ST_Area(n.geog) / 1000000.0) AS area_sqkm
    FROM phl.neighborhoods AS n
),

stops_joined AS (
    SELECT
        na.neighborhood_name,
        na.area_sqkm,
        s.wheelchair_boarding
    FROM neighborhood_area AS na
    JOIN septa.bus_stops AS s
        ON ST_Covers(na.geog, s.geog)
),

counts AS (
    SELECT
        neighborhood_name,
        MAX(area_sqkm) AS area_sqkm,
        SUM(CASE WHEN wheelchair_boarding = 1 THEN 1 ELSE 0 END) AS num_bus_stops_accessible,
        SUM(CASE WHEN wheelchair_boarding = 2 THEN 1 ELSE 0 END) AS num_bus_stops_inaccessible,
        COUNT(*) AS total_stops
    FROM stops_joined
    GROUP BY neighborhood_name
),

metrics AS (
    SELECT
        neighborhood_name,
        num_bus_stops_accessible,
        num_bus_stops_inaccessible,

        (num_bus_stops_accessible::numeric / NULLIF(total_stops, 0)) AS share_accessible,
        (num_bus_stops_accessible::numeric / NULLIF(area_sqkm, 0)) AS density_accessible,

        (
            (num_bus_stops_accessible::numeric / NULLIF(total_stops, 0))
            *
            (num_bus_stops_accessible::numeric / NULLIF(area_sqkm, 0))
        ) AS accessibility_metric

    FROM counts
)
SELECT
    neighborhood_name,
    ROUND(accessibility_metric::numeric, 3) AS accessibility_metric,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
FROM metrics
ORDER BY accessibility_metric DESC
LIMIT 5;
