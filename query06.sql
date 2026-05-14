/*
  Rate neighborhoods by their bus stop accessibility for wheelchairs. Use
  OpenDataPhilly's neighborhood dataset along with an appropriate dataset
  from the Septa GTFS bus feed. Use the [GTFS documentation]
  (https://gtfs.org/reference/static/) for help. Use some creativity in
  the metric you devise in rating neighborhoods.

*/

WITH neighborhood_stops AS (
    SELECT
        n.name AS neighborhood_name,
        s.stop_id,
        s.wheelchair_boarding
    FROM phl.neighborhoods AS n
    INNER JOIN septa.bus_stops AS s
        ON ST_COVERS(n.geog, ST_MAKEPOINT(s.stop_lon, s.stop_lat)::geography)
),

neighborhood_accessibility AS (
    SELECT
        neighborhood_name,
        COUNT(*) AS total_stops,
        SUM(CASE WHEN wheelchair_boarding = 1 THEN 1 ELSE 0 END) AS accessible_stops,
        SUM(CASE WHEN wheelchair_boarding = 2 THEN 1 ELSE 0 END) AS inaccessible_stops,
        SUM(CASE WHEN wheelchair_boarding = 0 THEN 1 ELSE 0 END) AS unknown_stops,
        ROUND(
            SUM(CASE WHEN wheelchair_boarding = 1 THEN 1 ELSE 0 END)::numeric
            / NULLIF(COUNT(*), 0), 2
        ) AS accessibility_ratio
    FROM neighborhood_stops
    GROUP BY neighborhood_name
)

SELECT
    neighborhood_name,
    total_stops,
    accessible_stops,
    inaccessible_stops,
    unknown_stops,
    accessibility_ratio,
    RANK() OVER (ORDER BY accessibility_ratio DESC, total_stops DESC) AS accessibility_rank
FROM neighborhood_accessibility
ORDER BY accessibility_rank;
