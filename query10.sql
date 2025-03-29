/*
You're tasked with giving more contextual information to rail stops to fill the `stop_desc` field in a GTFS feed. 
Using any of the data sets above, PostGIS functions (e.g., `ST_Distance`, `ST_Azimuth`, etc.), 
and PostgreSQL string functions, build a description (alias as `stop_desc`) for each stop. 
Feel free to supplement with other datasets (must provide link to data used so it's reproducible),
and other methods of describing the relationships. 
SQL's `CASE` statements may be helpful for some operations.
*/
ALTER TABLE septa.rail_stops ADD COLUMN geog geography;
UPDATE septa.rail_stops
SET geog = ST_MakePoint(stop_lon, stop_lat)::geography;
WITH closest_bus_stops AS (
    -- Calculate the closest bus stop to each rail stop
    SELECT DISTINCT ON (rail.stop_id)
        rail.stop_id,
        bus.stop_name AS bus_stop,
        ROUND(ST_Distance(
            ST_Transform(bus.geog::geometry, 26918), -- Transform bus stop to EPSG:26918 (meters)
            ST_Transform(rail.geog::geometry, 26918) -- Transform rail stop to EPSG:26918 (meters)
        )) AS distance
    FROM septa.bus_stops AS bus
    CROSS JOIN septa.rail_stops AS rail
    ORDER BY rail.stop_id, distance ASC
),
rail_routes AS (
    -- Aggregate rail route names for each rail stop
    SELECT
        rail.stop_id,
        CASE
        WHEN STRING_AGG(DISTINCT lines.route_name, ', ') = 'Airport, Chestnut Hill East, Chestnut Hill West, Fox Chase, Lansdale/Doylestown, Manayunk/Norristown, Media/Wawa, Paoli/Thorndale, Trenton, Warminster, West Trenton, Wilmington/Newark'
        THEN 'not found'
        ELSE COALESCE(STRING_AGG(DISTINCT lines.route_name, ', '), 'not found')
    END AS routes
    FROM septa.rail_lines AS lines
    RIGHT JOIN septa.rail_stops AS rail
        ON ST_DWithin(
        ST_Transform(rail.geog::geometry, 26918),  -- Transform rail stop to EPSG:26918 (meters)
        ST_Transform(lines.geog::geometry, 26918), -- Transform rail line to EPSG:26918 (meters)
        30
    )
    GROUP BY rail.stop_id
)
SELECT
    rail.stop_id,
    rail.stop_name,
    rail.stop_lat,
    rail.stop_lon,
    -- Create the stop description with the correct format
    COALESCE(
        'On/near the rail route "' || rail_routes.routes || '", ' ||
        closest_bus_stops.distance || ' meters away from the nearest bus stop "' || closest_bus_stops.bus_stop || '".',
        rail.stop_desc
    ) AS stop_desc -- Use COALESCE to ensure the original description is used if no match is found
FROM septa.rail_stops AS rail
-- Join with the closest bus stop data
LEFT JOIN closest_bus_stops
    ON rail.stop_id = closest_bus_stops.stop_id
-- Join with the rail routes data
LEFT JOIN rail_routes
    ON rail.stop_id = rail_routes.stop_id;