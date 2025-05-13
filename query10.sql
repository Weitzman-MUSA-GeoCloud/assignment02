/*
You're tasked with giving more contextual information to rail stops to fill the stop_desc field in a GTFS feed.
Using any of the data sets above, PostGIS functions (e.g., ST_Distance, ST_Azimuth, etc.), and PostgreSQL string functions,
build a description (alias as stop_desc) for each stop. Feel free to supplement with other datasets (must provide link to data used so it's reproducible),
and other methods of describing the relationships. SQL's CASE statements may be helpful for some operations.
*/

WITH nearest_parcel AS (
    SELECT
        r.stop_id,
        r.stop_name,
        r.stop_lon,
        r.stop_lat,
        r.geog AS stop_geog,
        p.address AS nearest_address,
        p.geog AS parcel_geog,
        ST_DISTANCE(r.geog, p.geog) AS dist_m
    FROM septa.rail_stops AS r
    INNER JOIN LATERAL (
        SELECT
            p.address,
            p.geog
        FROM phl.pwd_parcels AS p
        ORDER BY r.geog <-> p.geog
        LIMIT 1
    ) AS p ON TRUE
),

bus_counts AS (
    SELECT
        rs.stop_id,
        COUNT(bs.stop_id) AS bus_within_250m
    FROM septa.rail_stops AS rs
    LEFT JOIN septa.bus_stops AS bs
        ON ST_DWITHIN(rs.geog, bs.geog, 250)
    GROUP BY rs.stop_id
)

SELECT
    np.stop_id,
    np.stop_name,
    np.stop_lon,
    np.stop_lat,
    CONCAT(
        ROUND(np.dist_m)::int, ' m from ', INITCAP(np.nearest_address),
        '; ', COALESCE(bc.bus_within_250m, 0), ' bus stops within 250 m'
    ) AS stop_desc
FROM nearest_parcel AS np
LEFT JOIN bus_counts AS bc
    ON np.stop_id = bc.stop_id;
