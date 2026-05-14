CREATE INDEX IF NOT EXISTS idx_pop_geoid
ON census.population_2020 (geoid);

CREATE INDEX IF NOT EXISTS idx_blockgroups_geog
ON census.blockgroups_2020
USING GIST (geog);

ALTER TABLE septa.bus_stops ADD COLUMN IF NOT EXISTS geog geography(Point, 4326);

UPDATE septa.bus_stops
SET geog = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326)::geography
WHERE geog IS NULL;

CREATE INDEX IF NOT EXISTS bus_stops_geog_idx
ON septa.bus_stops USING GIST (geog);