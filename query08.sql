WITH meyerson AS (
    SELECT geog
    FROM phl.pwd_parcels
    WHERE address = '220-30 S 34TH ST'
),

penn_campus AS (
    SELECT ST_CONVEXHULL(ST_UNION(p.geog::geometry)) AS campus_geom
    FROM phl.pwd_parcels AS p, meyerson AS m
    WHERE (
        p.owner1 ILIKE '%TRUSTEES%UNIV%PENN%'
        OR p.owner1 ILIKE '%TRS%UNIV%PENN%'
        OR p.owner1 ILIKE '%TRUSTEES%PENNSYLVANIA%'
    )
    AND ST_DWITHIN(p.geog, m.geog, 800)
)

SELECT COUNT(*)::integer AS count_block_groups
FROM census.blockgroups_2020 AS bg, penn_campus AS pc
WHERE ST_CONTAINS(
    pc.campus_geom,
    bg.geog::geometry
);
