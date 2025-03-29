/*
Rate neighborhoods by their bus stop accessibility for wheelchairs. 
Use OpenDataPhilly's neighborhood dataset along with an appropriate dataset from the Septa GTFS bus feed. 
Use the [GTFS documentation](https://gtfs.org/reference/static/) for help. 
Use some creativity in the metric you devise in rating neighborhoods.
*/
CREATE TABLE phl.wheelchair_accessibility AS
WITH closest_bus_stops AS (
    -- Calculate the five closest bus stop to each neighborhood
    SELECT 
    hoods.mapname,
    stops.stop_id,
    CASE WHEN stops.wheelchair_boarding = 1 THEN 1 ELSE 0 END AS wheelchair_accessible,
    ROUND(ST_Distance(
        ST_Transform(stops.geog::geometry, 26918),  -- Convert bus stop to meters
        ST_Transform(ST_Centroid(hoods.geog::geometry), 26918)   -- Convert neighborhood to meters
    )) AS distance
FROM phl.neighborhoods AS hoods
JOIN LATERAL (
    SELECT 
        stops.stop_id,
        stops.wheelchair_boarding,
        stops.geog
    FROM septa.bus_stops AS stops
    ORDER BY stops.geog <-> hoods.geog  -- KNN index for fast nearest neighbor search
    LIMIT 5  -- Keep only the five closest bus stops per neighborhood
) AS stops ON TRUE
),
accessibility_scores AS (
    -- Calculate raw accessibility score
    SELECT 
        mapname AS neighborhood,
        SUM(wheelchair_accessible::float / (distance + 1)) AS raw_score
    FROM closest_bus_stops
    GROUP BY neighborhood
),
score_bounds AS (
    -- Get min & max scores for normalization
    SELECT 
        MIN(raw_score) AS min_score,
        MAX(raw_score) AS max_score
    FROM accessibility_scores
)
SELECT 
    a.neighborhood,
    ROUND(
        (10 * (a.raw_score - s.min_score) / NULLIF(s.max_score - s.min_score, 0))::NUMERIC, 2
    ) AS wheelchair_accessibility
FROM accessibility_scores a
CROSS JOIN score_bounds s
ORDER BY wheelchair_accessibility DESC;