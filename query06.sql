/*
What are the top five neighborhoods according to your
accessibility metric?
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
