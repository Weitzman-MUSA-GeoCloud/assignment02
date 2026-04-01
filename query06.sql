SELECT
    neighborhood_name,
    accessibility_metric,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
FROM neighborhood_accessibility
ORDER BY accessibility_metric DESC,
         num_bus_stops_accessible DESC,
         neighborhood_name
LIMIT 5;
