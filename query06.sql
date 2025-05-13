SET search_path TO public, phl, septa, census;

WITH stops_by_neighborhood AS (
    SELECT
        n.name AS neighborhood_name,
        COUNT(s.stop_id) AS num_bus_stops,
        COUNT(*) FILTER (WHERE s.wheelchair_boarding = 1) AS num_accessible,
        COUNT(*) FILTER (WHERE s.wheelchair_boarding IN (0, 2)) AS num_inaccessible,
        ST_Area(n.geog::geometry) / 1000000 AS area_sq_km
    FROM phl.neighborhoods AS n
    LEFT JOIN septa.bus_stops AS s
        ON ST_Within(s.geog::geometry, n.geog::geometry)
    GROUP BY n.name, n.geog
),
scored_neighborhoods AS (
    SELECT
        neighborhood_name,
        COALESCE(
            ROUND(
                CAST(
                    (num_accessible::numeric / NULLIF(area_sq_km, 0)) *
                    (num_accessible::numeric / NULLIF(num_bus_stops, 0))
                AS numeric),
                2
            ),
            0
        ) AS accessibility_metric
    FROM stops_by_neighborhood
)
SELECT *
FROM scored_neighborhoods
ORDER BY accessibility_metric DESC
LIMIT 5;
