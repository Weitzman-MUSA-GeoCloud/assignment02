/* Using the bus_shapes, bus_routes, and bus_trips tables from GTFS bus feed, 
find the two routes with the longest trips.

*/

WITH trip_lengths AS (
    -- Compute the total length of each trip's shape
    SELECT 
        t.route_id,
        t.trip_headsign,
        s.geog AS shape_geog,
        ROUND(ST_Length(s.geog::geography)) AS shape_length
    FROM septa.bus_trips AS t
    JOIN septa.bus_shapes AS s ON t.shape_id = s.shape_id
),

route_lengths AS (
    -- Assign route short names
    SELECT 
        r.route_short_name,
        tl.trip_headsign,
        tl.shape_geog,
        tl.shape_length
    FROM trip_lengths AS tl
    JOIN septa.bus_routes AS r ON tl.route_id = r.route_id
)

-- Select the top 2 longest trips
SELECT route_short_name, trip_headsign, shape_geog, shape_length
FROM route_lengths
ORDER BY shape_length DESC
LIMIT 2;
