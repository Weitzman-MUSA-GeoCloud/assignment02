/*
You're tasked with giving more contextual information to rail stops to fill the stop_desc field in a GTFS feed. Using any of the data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string functions, build a description (alias as stop_desc) for each stop. Feel free to supplement with other datasets (must provide link to data used so it's reproducible), and other methods of describing the relationships. SQL's CASE statements may be helpful for some operations.
*/

set search_path = public;

WITH
septa_bus_stops AS (
    SELECT
        stop_id,
        stop_name,
        ST_MakePoint(stop_lon, stop_lat)::geography AS geog
    FROM septa.bus_stops
),

septa_rail_stops AS (
    SELECT
        stop_id,
        stop_name,
        stop_lon,
        stop_lat,
        ST_MakePoint(stop_lon, stop_lat)::geography AS geog
    FROM septa.rail_stops
)
SELECT
    rail.stop_id,
    rail.stop_name,
    CONCAT(
        'In ',
        neighborhood.listname,
        ' neighborhood and ',
        ROUND(ST_Distance(rail.geog, nearest_bus_stop.geog)::numeric, 2),
        'm to nearest bus stop ',
        nearest_bus_stop.stop_id,
        ': ',
        nearest_bus_stop.stop_name
    ) AS stop_desc,
    rail.stop_lon,
    rail.stop_lat
FROM septa_rail_stops AS rail

CROSS JOIN LATERAL (
    SELECT stop_id, stop_name, geog
    FROM septa_bus_stops AS bus_stops
    ORDER BY rail.geog <-> bus_stops.geog
    LIMIT 1
) AS nearest_bus_stop
CROSS JOIN LATERAL (
    SELECT listname, geog
    FROM phl.neighborhoods AS nb
    ORDER BY rail.geog <-> nb.geog
    LIMIT 1
) AS neighborhood;