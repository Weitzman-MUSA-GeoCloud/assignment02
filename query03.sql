ALTER TABLE phl.pwd_parcels
ADD COLUMN IF NOT EXISTS geom geometry(MultiPolygon, 4326);

UPDATE phl.pwd_parcels
SET geom = geog::geometry
WHERE geom IS NULL;

CREATE INDEX IF NOT EXISTS idx_pwd_parcels_geom
ON phl.pwd_parcels
USING GIST (geom);

ALTER TABLE septa.bus_stops
ADD COLUMN IF NOT EXISTS geom geometry(Point, 4326);

UPDATE septa.bus_stops
SET geom = geog::geometry
WHERE geom IS NULL;

CREATE INDEX IF NOT EXISTS idx_bus_stops_geom
ON septa.bus_stops
USING GIST (geom);

SELECT
    p.address AS parcel_address,
    nearest.stop_name,
    ROUND(ST_Distance(p.geog, nearest.geog)::numeric, 2) AS distance
FROM phl.pwd_parcels AS p
CROSS JOIN LATERAL (
    SELECT
        s.stop_name,
        s.geog,
        s.geom
    FROM septa.bus_stops AS s
    ORDER BY p.geom <-> s.geom
    LIMIT 1
) AS nearest
ORDER BY distance DESC;