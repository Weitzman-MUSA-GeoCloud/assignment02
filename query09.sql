WITH meyerson_parcel AS (
    -- Find the parcel that corresponds to Meyerson Hall
    SELECT geog::geometry AS meyerson_geom
    FROM phl.pwd_parcels 
    WHERE address = '220-30 S 34TH ST' -- Meyerson Hall
)

SELECT bg.geoid
FROM census.blockgroups_2020 AS bg, meyerson_parcel AS mp
WHERE ST_Contains(bg.geog::geometry, mp.meyerson_geom);
