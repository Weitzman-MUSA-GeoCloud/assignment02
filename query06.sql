select
    neighborhood_name,
    parcels_near_accessible_stop as accessibility_metric,
    num_bus_stops_accessible,
    num_bus_stops_inaccessible
from phl.neighborhoods_accessibility2
order by accessibility_metric desc, num_bus_stops_accessible desc
limit 5;