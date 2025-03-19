WITH neighborhood_area AS (
    -- Get the total area of each neighborhood (assuming neighborhood.geom is a Polygon/MultiPolygon)
    SELECT 
        n.name AS neighborhood_name,
        ST_Area(n.geog::geography) / 1000000 AS area_km2  -- Convert area to square kilometers
    FROM phl.neighborhoods AS n
),

stop_counts AS (
    -- Count total stops and wheelchair-accessible stops per neighborhood
    SELECT 
        n.name AS neighborhood_name,
        COUNT(bs.stop_id) AS total_stops,
        SUM(CASE WHEN bs.wheelchair_boarding = 1 THEN 1 ELSE 0 END) AS accessible_stops,
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
        (sc.total_stops / na.area_km2) AS stop_density,
        (sc.accessible_stops::NUMERIC / NULLIF(sc.total_stops, 0)) AS accessible_stop_ratio,
        (sc.total_wheelchair_boardings::NUMERIC / NULLIF(sc.accessible_stops, 0)) AS avg_wheelchair_boardings_per_accessible_stop
    FROM stop_counts AS sc
    JOIN neighborhood_area AS na ON sc.neighborhood_name = na.neighborhood_name
),

final_accessibility_score AS (
    -- Compute the final accessibility metric as the product of all three indicators
    SELECT 
        neighborhood_name,
        stop_density,
        accessible_stop_ratio,
        avg_wheelchair_boardings_per_accessible_stop,
        (stop_density * accessible_stop_ratio * avg_wheelchair_boardings_per_accessible_stop) AS accessibility_score
    FROM calculated_metrics
)

-- Order neighborhoods by accessibility score (higher is better)
SELECT * FROM final_accessibility_score
ORDER BY accessibility_score DESC;
