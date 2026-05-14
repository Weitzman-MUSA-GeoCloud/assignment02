SELECT
    rs.stop_id::integer AS stop_id,
    rs.stop_name,
    rs.stop_lon,
    rs.stop_lat,
    CASE
        WHEN ST_INTERSECTS(nearest_nbhd.n_geog, rs.stop_pt_geog)
            THEN 'In the heart of ' || nearest_nbhd.name
        ELSE
            'A '
            || ROUND(ST_DISTANCE(rs.stop_pt_geog, nearest_nbhd.n_geog)::numeric / 80, 0)
            || '-minute walk '
            || CASE
                WHEN nearest_nbhd.deg >= 337.5 OR nearest_nbhd.deg < 22.5 THEN 'N'
                WHEN nearest_nbhd.deg >= 22.5 AND nearest_nbhd.deg < 67.5 THEN 'NE'
                WHEN nearest_nbhd.deg >= 67.5 AND nearest_nbhd.deg < 112.5 THEN 'E'
                WHEN nearest_nbhd.deg >= 112.5 AND nearest_nbhd.deg < 157.5 THEN 'SE'
                WHEN nearest_nbhd.deg >= 157.5 AND nearest_nbhd.deg < 202.5 THEN 'S'
                WHEN nearest_nbhd.deg >= 202.5 AND nearest_nbhd.deg < 247.5 THEN 'SW'
                WHEN nearest_nbhd.deg >= 247.5 AND nearest_nbhd.deg < 292.5 THEN 'W'
                WHEN nearest_nbhd.deg >= 292.5 AND nearest_nbhd.deg < 337.5 THEN 'NW'
            END
            || ' from ' || edge_parcel.address
            || ', at the edge of ' || nearest_nbhd.name
    END AS stop_desc
FROM (
    SELECT
        stop_id,
        stop_name,
        stop_lon,
        stop_lat,
        ST_SETSRID(ST_MAKEPOINT(stop_lon, stop_lat), 4326)::public.geography AS stop_pt_geog,
        ST_SETSRID(ST_MAKEPOINT(stop_lon, stop_lat), 4326) AS stop_pt_geom
    FROM septa.rail_stops
) AS rs
CROSS JOIN
    LATERAL (
        SELECT
            n.name,
            n.geog AS n_geog,
            ST_CLOSESTPOINT(n.geog::public.geometry, rs.stop_pt_geom) AS edge_pt_geom,
            DEGREES(
                ST_AZIMUTH(
                    ST_CLOSESTPOINT(n.geog::public.geometry, rs.stop_pt_geom),
                    rs.stop_pt_geom
                )
            ) AS deg
        FROM phl.neighborhoods AS n
        ORDER BY n.geog <-> rs.stop_pt_geog
        LIMIT 1
    ) AS nearest_nbhd
LEFT JOIN LATERAL (
    SELECT p.address
    FROM phl.pwd_parcels AS p
    WHERE p.address IS NOT NULL
    ORDER BY p.geog <-> nearest_nbhd.edge_pt_geom::public.geography
    LIMIT 1
) AS edge_parcel ON TRUE;
