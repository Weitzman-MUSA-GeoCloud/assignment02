-- Active: 1769632283990@@127.0.0.1@5432@assignment02
/*
Rate neighborhoods by their bus stop accessibility for wheelchairs.
Use OpenDataPhilly's neighborhood dataset along with an appropriate dataset from the Septa GTFS bus feed. Use the GTFS documentation for help. Use some creativity in the metric you devise in rating neighborhoods.

NOTE: There is no automated test for this question, as there's no one
right answer. With urban data analysis, this is frequently the case.

Discuss your accessibility metric and how you arrived at it below:
*/

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
    accessibility_metric DESC;
