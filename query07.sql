WITH neighborhood_stop_counts AS (
    SELECT
        n.name AS neighborhood_name,
        COUNT(*) FILTER (WHERE s.wheelchair_boarding = 1) AS num_bus_stops_accessible,
        COUNT(*) FILTER (
            WHERE s.wheelchair_boarding IS DISTINCT FROM 1
        ) AS num_bus_stops_inaccessible
    FROM phl.neighborhoods AS n
    JOIN septa.bus_stops AS s
        ON ST_Intersects(n.geog::geometry, s.geog::geometry)
    GROUP BY n.name
),

neighborhood_accessibility AS (
    SELECT
        neighborhood_name,
        ROUND(
            (
                num_bus_stops_accessible::numeric /
                NULLIF(num_bus_stops_accessible + num_bus_stops_inaccessible, 0)
            ),
            4
        ) AS accessibility_metric,
        num_bus_stops_accessible,
        num_bus_stops_inaccessible
    FROM neighborhood_stop_counts
)

SELECT
    neighborhood_name,
    accessibility_metric,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
FROM neighborhood_accessibility
ORDER BY
    accessibility_metric ASC,            -- ❗改这里（最重要）
    num_bus_stops_accessible ASC,        -- 次排序（少的更差）
    neighborhood_name
LIMIT 5;