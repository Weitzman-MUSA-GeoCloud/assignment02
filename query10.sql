-- Active: 1738180041736@@localhost@5432@musa_509
/*
You're tasked with giving more contextual information to rail stops to fill the stop_desc field in a GTFS feed.
Using any of the data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string functions,
build a description (alias as stop_desc) for each stop.
*/


SELECT
    rail.stop_id,
    rail.stop_name,
    CONCAT(COUNT(bus.stop_id), ' bus stops within 500 m') AS stop_desc,
    rail.stop_lon,
    rail.stop_lat
FROM
    septa.rail_stops AS rail
LEFT JOIN
    septa.bus_stops AS bus
    ON
        public.ST_DWithin(
            public.ST_SetSRID(public.ST_MakePoint(rail.stop_lon, rail.stop_lat), 4326),
            bus.geog,
            500
        )
GROUP BY
    rail.stop_id, rail.stop_name, rail.stop_lon, rail.stop_lat
ORDER BY
    rail.stop_id;
