/*What are the bottom five neighborhoods according to your accessibility metric?*/

SELECT
    phl.neighborhoods.name AS neighborhood_name,
    COUNT(CASE WHEN septa.bus_stops.wheelchair_boarding = 1 THEN 1 END)::integer AS accessibility_metric,
    COUNT(CASE WHEN septa.bus_stops.wheelchair_boarding = 1 THEN 1 END)::integer AS num_bus_stops_accessible,
    COUNT(CASE WHEN septa.bus_stops.wheelchair_boarding = 2 THEN 1 END)::integer AS num_bus_stops_inaccessible
FROM
    phl.neighborhoods
LEFT JOIN septa.bus_stops
    ON public.ST_Intersects(phl.neighborhoods.geog, septa.bus_stops.geog)
GROUP BY
    phl.neighborhoods.name
ORDER BY
    accessibility_metric ASC
LIMIT 5;
