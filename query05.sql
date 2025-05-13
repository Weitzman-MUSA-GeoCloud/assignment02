/*
Rate neighborhoods by their bus stop accessibility for wheelchairs.
 Use OpenDataPhilly's neighborhood dataset along with an appropriate dataset from the Septa GTFS bus feed.
 Use the GTFS documentation for help.
 Use some creativity in the metric you devise in rating neighborhoods.
*/

-- Goal: Develop a composite Wheelchair Accessibility Score (WAS) for Philadelphia neighborhoods
--
-- Rate Philadelphia neighborhoods by their wheelchair-accessible bus stop service,
-- using two sub-metrics:
--   1) Density of accessible stops (stops per km²)
--   2) Share of stops that are accessible (0 – 1)
-- Final score is the average of a normalized density and the accessibility share.

/*
Why these metrics?
  • Density of accessible stops (accessible stops per km²)
      – Normalizes for neighborhood size so that small and large areas are comparable.
      – Rewards areas where accessible stops are spatially concentrated.
  • Share of stops that are accessible (0–1)
      – Captures relative service quality: what fraction of all stops a person in a wheelchair can actually use.
      – Balances raw density with system-wide accessibility performance.

Final score = average of:
  1) density normalized to [0–1] across all neighborhoods
  2) accessibility share

This approach gives equal weight to spatial coverage and overall stop quality.
*/

WITH neighborhood_stats AS (
    SELECT
        n.name AS neighborhood,
        -- total number of bus stops in the neighborhood
        COUNT(s.stop_id) FILTER (WHERE TRUE) AS count_stops,
        -- total number of wheelchair-accessible stops
        COUNT(s.stop_id) FILTER (WHERE s.wheelchair_boarding = 1) AS count_wc_stops,
        -- area in square kilometers
        ST_AREA(n.geog::geometry)::numeric / 1e6 AS area_km2
    FROM phl.neighborhoods AS n
    LEFT JOIN septa.bus_stops AS s
      ON ST_WITHIN(s.geog::geometry, n.geog::geometry)
    GROUP BY n.name, n.geog
),

metrics AS (
    SELECT
        neighborhood,
        -- accessible stop density per km²
        count_wc_stops::double precision / NULLIF(area_km2, 0) AS density,
        -- proportion of all stops that are accessible
        count_wc_stops::double precision / NULLIF(count_stops, 0) AS accessibility_ratio
    FROM neighborhood_stats
),

normalized_density AS (
    SELECT
        neighborhood,
        density,
        accessibility_ratio,
        -- normalize density to a 0–1 scale across neighborhoods
        (density - MIN(density) OVER()) 
          / NULLIF(MAX(density) OVER() - MIN(density) OVER(), 0) 
        AS density_norm
    FROM metrics
),

composite_score AS (
    SELECT
        neighborhood,
        density,
        accessibility_ratio,
        density_norm,
        -- composite score: average of normalized density and accessibility ratio
        (density_norm + accessibility_ratio) / 2.0 
        AS wheelchair_access_score
    FROM normalized_density
)

SELECT
    neighborhood,
    ROUND(wheelchair_access_score, 3) AS access_score
FROM composite_score
ORDER BY access_score DESC;