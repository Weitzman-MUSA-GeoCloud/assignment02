-- Active: 1738180041736@@localhost@5432@musa_509
/*
This query calculates a relative metric designed for comparison purposes. 
It evaluates the number of wheelchair-accessible stations per unit area of each neighborhood. 
Essentially, it divides the count of accessible stations by the neighborhood's area. 
It's likely to result in a small value for neighborhoods with smaller areas, it should still provide a straightforward comparisons between neighborhoods.
*/


SET search_path TO assignment2;

-- table to store the accessibility metrics
CREATE TABLE assignment2.phlmetrics AS
WITH resolved_stops AS (
    SELECT
        bs.stop_id,
        bs.geog,
        CASE
            WHEN bs.wheelchair_boarding = 0 AND bs.parent_station IS NOT NULL THEN ps.wheelchair_boarding
            ELSE bs.wheelchair_boarding
        END AS resolved_wheelchair_boarding
    FROM
        septa.bus_stops AS bs
    LEFT JOIN
        septa.bus_stops ps ON bs.parent_station = ps.stop_id
),
neighbourhood_accessibility AS (
    SELECT
        n.name,
        COUNT(CASE WHEN rs.resolved_wheelchair_boarding = 1 THEN 1 END) AS num_bus_stop_accessible,
        COUNT(CASE WHEN rs.resolved_wheelchair_boarding = 2 THEN 1 END) AS num_bus_stop_inaccessible,
        public.ST_Area(n.geog) AS neighbourhood_area
    FROM
        phl.neighborhoods AS n
    LEFT JOIN
        resolved_stops rs ON public.ST_Contains(n.geog::public.geometry, rs.geog::public.geometry)
    GROUP BY
        n.name, n.geog
)
SELECT
    name AS neighbourhood_name,
    COALESCE(num_bus_stop_accessible / NULLIF(neighbourhood_area, 0) * 10000, 0) AS accessibility_metric,
    num_bus_stop_accessible,
    num_bus_stop_inaccessible
FROM
    neighbourhood_accessibility;