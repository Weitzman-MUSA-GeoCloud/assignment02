/*
 3.  Using the Philadelphia Water Department Stormwater Billing Parcels dataset, pair each parcel with its closest bus stop. The final result should give the parcel address, bus stop name, and distance apart in meters, rounded to two decimals. Order by distance (largest on top).

*/

CREATE INDEX IF NOT EXISTS bus_stops_geog_gix
ON septa.bus_stops
USING GIST (geog);

CREATE INDEX IF NOT EXISTS pwd_parcel_geo_gist
ON phl.pwd_parcels
USING GIST (geog);

set search_path = public


SELECT
  p.address AS parcel_address,
  s.stop_name,
  ROUND(ST_Distance(p.geog, s.geog)::numeric, 2) AS distance
FROM phl.pwd_parcels AS p
JOIN LATERAL (
  SELECT
    stop_name,
    geog
  FROM septa.bus_stops
  ORDER BY septa.bus_stops.geog <-> p.geog
  LIMIT 1
) AS s ON TRUE
ORDER BY distance DESC;
