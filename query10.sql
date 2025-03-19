WITH nearest_stop AS (
    -- Find the nearest other rail stop
    SELECT 
        rs1.stop_id,
        rs1.stop_name,
        rs1.stop_lon,
        rs1.stop_lat,
        rs2.stop_name AS nearest_stop_name,
        ST_Distance(rs1.geog::geography, rs2.geog::geography) AS distance_meters,
        ST_Azimuth(rs1.geog::geometry, rs2.geog::geometry) AS azimuth_radians,
        RANK() OVER (PARTITION BY rs1.stop_id ORDER BY ST_Distance(rs1.geog::geography, rs2.geog::geography)) AS rank
    FROM septa.rail_stops AS rs1
    JOIN septa.rail_stops AS rs2 
        ON rs1.stop_id <> rs2.stop_id -- Avoid self-join on the same stop
),

direction_labels AS (
    -- Convert azimuth radians into cardinal directions
    SELECT 
        stop_id,
        stop_name,
        stop_lon,
        stop_lat,
        nearest_stop_name,
        ROUND(distance_meters) AS distance_meters,
        CASE 
            WHEN azimuth_radians BETWEEN 0 AND PI()/8 THEN 'N'
            WHEN azimuth_radians BETWEEN PI()/8 AND 3*PI()/8 THEN 'NE'
            WHEN azimuth_radians BETWEEN 3*PI()/8 AND 5*PI()/8 THEN 'E'
            WHEN azimuth_radians BETWEEN 5*PI()/8 AND 7*PI()/8 THEN 'SE'
            WHEN azimuth_radians BETWEEN 7*PI()/8 AND 9*PI()/8 THEN 'S'
            WHEN azimuth_radians BETWEEN 9*PI()/8 AND 11*PI()/8 THEN 'SW'
            WHEN azimuth_radians BETWEEN 11*PI()/8 AND 13*PI()/8 THEN 'W'
            WHEN azimuth_radians BETWEEN 13*PI()/8 AND 15*PI()/8 THEN 'NW'
            ELSE 'N'
        END AS direction
    FROM nearest_stop
    WHERE rank = 1 -- Select the closest stop
),

final_stop_descriptions AS (
    -- Construct stop descriptions
    SELECT 
        stop_id,
        stop_name,
        stop_lon,
        stop_lat,
        CONCAT(distance_meters, ' meters ', direction, ' of ', nearest_stop_name) AS stop_desc
    FROM direction_labels
)

-- Final selection
SELECT stop_id, stop_name, stop_desc, stop_lon, stop_lat
FROM final_stop_descriptions;

