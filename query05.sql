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
            ST_Transform(ns.geog::geometry, 4326)  -- Convert geography to geometry, then apply ST_Transform
        )
    GROUP BY
        ns.name
)
SELECT
    neighborhood_name,
    total_bus_stops,
    accessible_bus_stops,
    (accessible_bus_stops::float / total_bus_stops) * 100 AS accessibility_percentage  -- Calculate the accessibility percentage
FROM
    neighborhood_bus_stop_counts
ORDER BY
    accessibility_percentage DESC;
