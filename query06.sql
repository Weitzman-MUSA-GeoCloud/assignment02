WITH stop_trip_access AS (
    SELECT DISTINCT
        st.stop_id,
        t.wheelchair_accessible
    FROM septa.bus_trips t
    JOIN septa.stop_times st
        ON t.trip_id = st.trip_id
),

neighborhood_stops AS (
    SELECT
        n.name AS neighborhood_name,
        s.stop_id,
        sta.wheelchair_accessible
    FROM phl.neighborhoods n
    JOIN septa.bus_stops s
        ON ST_Intersects(n.geog, s.geog)
    LEFT JOIN stop_trip_access sta
        ON s.stop_id = sta.stop_id
),

aggregated AS (
    SELECT
        neighborhood_name,
        COUNT(*) FILTER (WHERE wheelchair_accessible = 1) AS num_bus_stops_accessible,
        COUNT(*) FILTER (WHERE wheelchair_accessible IS DISTINCT FROM 1) AS num_bus_stops_inaccessible,
        COUNT(*) AS total_stops
    FROM neighborhood_stops
    GROUP BY neighborhood_name
)

SELECT
    neighborhood_name,
    (num_bus_stops_accessible::float / total_stops) AS accessibility_metric,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
FROM aggregated
ORDER BY accessibility_metric DESC
LIMIT 5;
