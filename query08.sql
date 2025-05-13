/*
Find out how many census block groups Penn's main campus fully contains.
Discuss which dataset you chose for defining Penn's campus.
*/

/*
Discussion:
Dataset chosen: phl.policeboundary (UPenn Police patrol zone)
– Official boundary maintained by University Public Safety
– Covers core campus and outlying sites under campus jurisdiction
– Single, authoritative GIS layer ensures reproducible results
- https://www.publicsafety.upenn.edu/about/uppd/
*/

SELECT COUNT(*) AS count_block_groups
FROM census.blockgroups_2020 AS bg
INNER JOIN phl.policeboundary AS pp
  ON ST_Contains(
       ST_Transform(pp.geog::geometry, 4326),
       ST_Transform(bg.geog::geometry, 4326)
     );