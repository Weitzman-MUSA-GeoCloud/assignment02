/*
With a query, find out how many census block groups Penn's main campus fully contains. Discuss which dataset you chose for defining Penn's campus.
*/
SELECT COUNT(*) AS count_block_groups
FROM census.blockgroups_2020 AS bg
INNER JOIN phl.campus AS camp
    ON public.ST_Contains(public.ST_Transform(camp.geog::geometry, 4326), public.ST_Transform(bg.geog::geometry, 4326));

-- Campus boundary given by the Penn Police patrol boundary
--- from: https://www.publicsafety.upenn.edu/about/uppd/