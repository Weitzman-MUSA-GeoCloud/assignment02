WITH neighborhood_area AS (
    -- Get the total area of each neighborhood in square kilometers
    SELECT 
        n.name AS neighborhood_name,
        ST_Area(n.geog::geography) / 1000000 AS area_km2  -- Convert area to square km
    FROM phl.neighborhoods AS n
),

stop_counts AS (
    -- Count total stops and wheelchair-accessible stops per neighborhood
    SELECT 
        n.name AS neighborhood_name,
        COUNT(bs.stop_id) AS total_stops,
        SUM(CASE WHEN bs.wheelchair_boarding = 1 THEN 1 ELSE 0 END) AS num_bus_stops_accessible,
		SUM(CASE WHEN bs.wheelchair_boarding = 2 OR bs.wheelchair_boarding = 0 THEN 1 ELSE 0 END) AS num_bus_stops_inaccessible,
        SUM(bs.wheelchair_boarding) AS total_wheelchair_boardings
    FROM septa.bus_stops AS bs
    JOIN phl.neighborhoods AS n
        ON ST_Intersects(bs.geog, n.geog) -- Match stops to neighborhoods
    GROUP BY n.name
),

calculated_metrics AS (
    -- Compute stop density, accessible stop ratio, and avg wheelchair boardings
    SELECT 
        sc.neighborhood_name,
		num_bus_stops_accessible,
		num_bus_stops_inaccessible,
        (sc.total_stops / na.area_km2) AS accessibility_metric
    FROM stop_counts AS sc
    JOIN neighborhood_area AS na ON sc.neighborhood_name = na.neighborhood_name
),

final_accessibility_score AS (
    -- Compute the final accessibility metric
    SELECT 
        neighborhood_name,
        accessibility_metric,
		num_bus_stops_inaccessible,
		num_bus_stops_accessible
    FROM calculated_metrics
)

-- Select the bottom 5 neighborhoods with the highest accessibility scores
SELECT neighborhood_name, accessibility_metric, num_bus_stops_accessible, num_bus_stops_inaccessible
FROM final_accessibility_score
ORDER BY accessibility_metric deSC
LIMIT 5;