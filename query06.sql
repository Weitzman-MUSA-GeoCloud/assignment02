WITH bus_stops_neighborhoods AS (
    SELECT
        n.mapname AS neighborhood_name,
        s.stop_id,
        CASE WHEN s.wheelchair_boarding = 1 THEN 1 ELSE 0 END AS accessible,
        CASE WHEN s.wheelchair_boarding = 2 THEN 1 ELSE 0 END AS inaccessible
    FROM phl.neighborhoods AS n
    JOIN septa.bus_stops AS s -- noqa: AM05
        ON ST_INTERSECTS(s.geog, n.geog)
),

accessibility_summary AS (
    SELECT
        neighborhood_name,
        ROUND(
            CASE
                WHEN COUNT(*) > 0 THEN (SUM(accessible)::numeric / COUNT(*)) * 100
            END, 2
        ) AS accessibility_metric,
        SUM(accessible) AS num_bus_stops_accessible,
        SUM(inaccessible) AS num_bus_stops_inaccessible
    FROM bus_stops_neighborhoods
    GROUP BY neighborhood_name
)

SELECT
    neighborhood_name,
    accessibility_metric,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
FROM accessibility_summary
ORDER BY accessibility_metric DESC NULLS LAST
LIMIT 5;
