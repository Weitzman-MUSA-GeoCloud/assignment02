/*
Rate neighborhoods by their bus stop accessibility for wheelchairs. Use OpenDataPhilly's neighborhood dataset along with an appropriate dataset from the Septa GTFS bus feed. Use the GTFS documentation for help. Use some creativity in the metric you devise in rating neighborhoods.
*/
set search_path = public;

WITH stop_accessibility AS (
    SELECT 
        stop_id,
        stop_name,
        stop_lon,
        stop_lat,
        CASE 
            WHEN wheelchair_boarding = 1 THEN 1
            ELSE 0
        END AS accessibility
    FROM septa.bus_stops
),
nb_accessible AS (
    SELECT 
        nb.listname AS neighborhood, 
        COUNT(sa.stop_id) AS num_stops,
        SUM(sa.accessibility) AS num_accessible_stops,
        ROUND(
            SUM(sa.accessibility)::numeric / COUNT(sa.stop_id) * 100,
            2
        ) AS pct_stops_accessible
    FROM phl.neighborhoods nb
    JOIN stop_accessibility sa
      ON ST_Within(
           ST_SetSRID(
             ST_MakePoint(sa.stop_lon::float, sa.stop_lat::float),
             4326
           ),
           nb.geog::geometry
         )
    GROUP BY nb.listname
)
SELECT 
    neighborhood,
    num_stops,
    num_accessible_stops,
    pct_stops_accessible
FROM nb_accessible
ORDER BY pct_stops_accessible;

/*

Description: 

Rate neighborhoods by their bus stop accessibility for wheelchairs. Use OpenDataPhilly's neighborhood dataset along with an appropriate dataset from the Septa GTFS bus feed. Use the GTFS documentation for help. Use some creativity in the metric you devise in rating neighborhoods.

*/