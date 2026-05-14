/*
10. You're tasked with giving more contextual information to rail stops to fill the `stop_desc` field in a GTFS feed. Using any of the data sets above, PostGIS functions (e.g., `ST_Distance`, `ST_Azimuth`, etc.), and PostgreSQL string functions, build a description (alias as `stop_desc`) for each stop. Feel free to supplement with other datasets (must provide link to data used so it's reproducible), and other methods of describing the relationships. SQL's `CASE` statements may be helpful for some operations.
*/

set search_path = public

WITH stops AS (
    SELECT
        stop_id::int,
        stop_name::text,
        stop_lon::double precision,
        stop_lat::double precision,
        ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326)::geography AS stop_geog,
        ST_Transform(
            ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326),
            3857
        ) AS stop_pt_3857
    FROM septa.rail_stops
),

nearest_parcel AS (
    SELECT
        s.*,
        p.geog AS parcel_geog,
        p.address::text AS parcel_addr,

        ST_Transform(
            ST_Centroid(p.geog::geometry),
            3857
        ) AS parcel_pt_3857

    FROM stops s
    JOIN LATERAL (
        SELECT geog, address
        FROM phl.pwd_parcels
        WHERE geog IS NOT NULL
        ORDER BY s.stop_geog <-> geog
        LIMIT 1
    ) p ON TRUE
),

final AS (
    SELECT
        stop_id,
        stop_name,
        stop_lon,
        stop_lat,
        parcel_addr,

        ROUND(ST_Distance(stop_geog, parcel_geog))::int AS dist_m,

        degrees(
            ST_Azimuth(parcel_pt_3857, stop_pt_3857)
        ) AS az_deg

    FROM nearest_parcel
)
SELECT
    stop_id,
    stop_name,

    (
        dist_m::text
        || ' meters '
        || CASE
            WHEN az_deg >= 337.5 OR az_deg < 22.5 THEN 'N'
            WHEN az_deg < 67.5  THEN 'NE'
            WHEN az_deg < 112.5 THEN 'E'
            WHEN az_deg < 157.5 THEN 'SE'
            WHEN az_deg < 202.5 THEN 'S'
            WHEN az_deg < 247.5 THEN 'SW'
            WHEN az_deg < 292.5 THEN 'W'
            ELSE 'NW'
          END
        || ' of '
        || COALESCE(parcel_addr, 'nearest parcel')
    )::text AS stop_desc,

    stop_lon,
    stop_lat

FROM final
ORDER BY stop_id;
