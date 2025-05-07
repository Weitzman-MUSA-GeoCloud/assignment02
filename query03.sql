SELECT parcels.address AS parcel_address,
       stops.stop_name AS stop_name,
       ROUND(CAST(stops.dist AS numeric), 2) AS dist
FROM phl.pwd_parcels parcels
CROSS JOIN LATERAL (
  SELECT stops.stop_name, stops.geog, stops.stop_id, stops.geog <-> parcels.geog AS dist
  FROM septa.bus_stops AS stops
  WHERE ST_DWithin(stops.geog, parcels.geog, 1000)  -- Adjust distance as needed (1000 meters in this example)
  ORDER BY dist
  LIMIT 1
) stops;