SELECT
    COUNT(DISTINCT bg.geoid) AS num_blockgroups
FROM census.blockgroups_2020 bg
JOIN phl.university_city u
    ON ST_Intersects(bg.geog, u.geog)
WHERE u.name ILIKE '%Penn%';
