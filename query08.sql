SET search_path TO public, phl, septa, census;
WITH penn_parcels AS (
    SELECT 
        ST_Union(ST_Transform(geog::geometry, 2272)) AS geom
    FROM phl.pwd_parcels
    WHERE 
        owner1 ILIKE ANY (ARRAY[
            '%TRUSTEES OF THE UNIVERSIT%',
            '%TRS UNIV OF PENN%',
            '%UNIV OF PENNSYLVANIA%'
        ])
),
block_groups_with_coverage AS (
    SELECT 
        bg.geoid,
        bg.geog,
        ST_Area(ST_Transform(bg.geog::geometry, 2272)) AS bg_area,
        ST_Area(ST_Intersection(
            ST_Transform(bg.geog::geometry, 2272),
            pp.geom
        )) AS intersect_area
    FROM census.blockgroups_2020 AS bg
    CROSS JOIN penn_parcels AS pp
    WHERE ST_Intersects(
        ST_Transform(bg.geog::geometry, 2272),
        pp.geom
    )
)
SELECT COUNT(*) AS count_block_groups
FROM block_groups_with_coverage
WHERE intersect_area >= 0.2 * bg_area;
