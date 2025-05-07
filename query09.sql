SELECT 
    bg.geoid
FROM 
    census.blockgroups_2020 bg
WHERE 
    ST_Within(
        ST_SetSRID(ST_MakePoint(-75.192584, 39.952415), 4326)::geometry,
        bg.geog::geometry
    )
LIMIT 1;
