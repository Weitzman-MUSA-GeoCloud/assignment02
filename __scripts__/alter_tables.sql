SET search_path = "public";

ALTER TABLE septa.bus_stops ADD COLUMN IF NOT EXISTS geom GEOMETRY (POINT, 4326);
ALTER TABLE septa.bus_stops ADD COLUMN IF NOT EXISTS geog GEOGRAPHY;

UPDATE septa.bus_stops
SET geom = ST_SETSRID(ST_MAKEPOINT(stop_lon, stop_lat), 4326)
WHERE (stop_lon IS NOT NULL) AND (stop_lat IS NOT NULL);

UPDATE septa.bus_stops
SET geog = geom::GEOGRAPHY
WHERE (stop_lon IS NOT NULL) AND (stop_lat IS NOT NULL);

ALTER TABLE phl.pwd_parcels DROP COLUMN IF EXISTS geom;
ALTER TABLE phl.pwd_parcels ADD COLUMN IF NOT EXISTS geom GEOMETRY (MULTIPOLYGON, 4326);
UPDATE phl.pwd_parcels
SET geom = geog::GEOMETRY;


CREATE INDEX septa_bus_stops_geog_idx
  ON septa.bus_stops
  USING GIST (geog);

CREATE INDEX neighborhood_geog_idx
  ON phl.neighborhoods
  USING GIST (geog);

CREATE INDEX parcel_geog_idx
  ON phl.pwd_parcels
  USING GIST (geog);