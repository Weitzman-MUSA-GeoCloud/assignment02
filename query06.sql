-- CTE to calculate accessibility for each neighborhood
WITH neighborhood_bus_stop_counts AS (
    SELECT
        ns.name AS neighborhood_name,
        COUNT(bs.stop_id) AS total_bus_stops,
        COUNT(CASE WHEN bs.wheelchair_boarding = 1 THEN 1 END) AS accessible_bus_stops
    FROM
        phl.neighborhoods ns
    JOIN
        septa.bus_stops bs
        ON ST_Within(
            ST_SetSRID(ST_MakePoint(bs.stop_lon, bs.stop_lat), 4326), 
            ST_Transform(ns.geog::geometry, 4326)
        )
    GROUP BY
        ns.name
),
accessibility_metric AS (
    SELECT
        neighborhood_name,
        accessible_bus_stops,
        total_bus_stops,
        (accessible_bus_stops::float / total_bus_stops) * 100 AS accessibility_percentage
    FROM
        neighborhood_bus_stop_counts
)

SELECT 
    neighborhood_name,
    accessibility_percentage AS accessibility_metric,
    accessible_bus_stops AS num_bus_stops_accessible,
    (total_bus_stops - accessible_bus_stops) AS num_bus_stops_inaccessible
FROM 
    accessibility_metric
ORDER BY 
    accessibility_percentage DESC,
	accessible_bus_stops DESC
LIMIT 5;
