/*
Rate neighborhoods by their bus stop accessibility for wheelchairs.
Use OpenDataPhilly's neighborhood dataset along with an appropriate
dataset from the Septa GTFS bus feed. Use the GTFS documentation for
help. Use some creativity in the metric you devise in rating neighborhoods.
*/

SELECT
    neighborhoods.listname AS neighborhood_name,
    round(
        count(*) FILTER (WHERE stops.wheelchair_boarding = 1)::numeric
        / nullif(count(*), 0) * 100,
        1
    ) AS accessibility_metric,
    count(*) FILTER (WHERE stops.wheelchair_boarding = 1) AS num_bus_stops_accessible,
    count(*) FILTER (WHERE stops.wheelchair_boarding = 2) AS num_bus_stops_inaccessible
FROM phl.neighborhoods AS neighborhoods
INNER JOIN septa.bus_stops AS stops
    ON st_within(stops.geog::geometry, neighborhoods.geog::geometry)
GROUP BY neighborhoods.listname
ORDER BY accessibility_metric DESC
LIMIT 5
