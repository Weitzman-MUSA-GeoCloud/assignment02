-- cardinal direction function from https://trac.osgeo.org/postgis/wiki/UsersWikiCardinalDirection
create or replace function ST_CARDINALDIRECTION(azimuth float8) returns character varying as
$BODY$SELECT CASE
  WHEN $1 < 0.0 THEN 'less than 0'
  WHEN degrees($1) < 22.5 THEN 'N'
  WHEN degrees($1) < 67.5 THEN 'NE'
  WHEN degrees($1) < 112.5 THEN 'E'
  WHEN degrees($1) < 157.5 THEN 'SE'
  WHEN degrees($1) < 202.5 THEN 'S'
  WHEN degrees($1) < 247.5 THEN 'SW'
  WHEN degrees($1) < 292.5 THEN 'W'
  WHEN degrees($1) < 337.5 THEN 'NW'
  WHEN degrees($1) <= 360.0 THEN 'N'
END;$BODY$ language sql immutable cost 100;
comment on function ST_CARDINALDIRECTION(float8) is 'input azimuth in radians; returns N, NW, W, SW, S, SE, E, or NE';

-- query code
with info as (
    select
        stops.stop_id,
        stops.stop_name,
        stops.stop_lon,
        stops.stop_lat,
        nbhds.listname as neighborhood,
        TO_CHAR(ROUND(knn.distance::numeric, 2)::real, '9D99') || ' meters ' as distance,
        ST_CARDINALDIRECTION(ST_AZIMUTH(ST_CENTROID(knn.parcel_geog), stops.geog)) as direction,
        INITCAP(knn.parcel_address) as parcel_address
    from septa.bus_stops as stops
    inner join phl.neighborhoods as nbhds
        on ST_INTERSECTS(stops.geog, nbhds.geog)
    cross join
        lateral (
            select
                parcels.geog as parcel_geog,
                parcels.address as parcel_address,
                parcels.geog <-> stops.geog as distance
            from phl.pwd_parcels as parcels
            order by distance asc
            limit 1
        ) as knn
)

select
    stop_id,
    stop_name,
    stop_lon,
    stop_lat,
    'In ' || neighborhood || ',' || distance || direction || ' of ' || parcel_address as stop_desc
from info;
