/*
What are the bottom five neighborhoods according to your accessibility metric?
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
        nb.listname AS neighborhood_name, 
        COUNT(sa.stop_id) AS num_bus_stops,
        SUM(sa.accessibility) AS num_bus_stops_accessible,
        COUNT(sa.stop_id) - SUM(sa.accessibility) AS num_bus_stops_inaccessible,
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
    neighborhood_name,
    pct_stops_accessible,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
FROM nb_accessible
ORDER BY pct_stops_accessible ASC, num_bus_stops_accessible ASC
LIMIT 5;