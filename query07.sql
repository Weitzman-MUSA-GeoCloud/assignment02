/*
  Bottom five neighborhoods
*/

WITH neighborhood_stats AS (
    SELECT
        n.name AS neighborhood,
        COUNT(s.stop_id) FILTER (WHERE TRUE) AS count_stops,
        COUNT(s.stop_id) FILTER (WHERE s.wheelchair_boarding = 1) AS count_wc_stops,
        ST_AREA(n.geog::geometry)::numeric / 1e6 AS area_km2
    FROM phl.neighborhoods AS n
    LEFT JOIN septa.bus_stops AS s
        ON ST_WITHIN(s.geog::geometry, n.geog::geometry)
    GROUP BY n.name, n.geog
),

metrics AS (
    SELECT
        neighborhood,
        count_stops,
        count_wc_stops,
        count_wc_stops::double precision / NULLIF(area_km2, 0) AS density,
        count_wc_stops::double precision / NULLIF(count_stops, 0) AS accessibility_ratio
    FROM neighborhood_stats
),

normalized_density AS (
    SELECT
        neighborhood,
        count_stops,
        count_wc_stops,
        accessibility_ratio,
        (density - MIN(density) OVER ())
        / NULLIF(MAX(density) OVER () - MIN(density) OVER (), 0)
        AS density_norm
    FROM metrics
),

composite_score AS (
    SELECT
        neighborhood,
        count_stops,
        count_wc_stops,
        (density_norm + accessibility_ratio) / 2.0 AS wheelchair_access_score
    FROM normalized_density
)

SELECT
    neighborhood AS neighborhood_name,
    count_wc_stops AS num_bus_stops_accessible,
    ROUND(wheelchair_access_score, 3) AS accessibility_metric,
    (count_stops - count_wc_stops) AS num_bus_stops_inaccessible
FROM composite_score
ORDER BY access_score ASC
LIMIT 5;
