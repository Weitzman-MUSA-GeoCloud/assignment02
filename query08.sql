/*
  How many census block groups does Penn's main campus fully contain?

  Penn's main campus boundary is defined as a bounding box approximating the
  core academic campus: roughly 32nd St to 40th St (east to west) and
  Walnut St to Baltimore Ave (north to south), using coordinates
  (-75.2010, 39.9430) to (-75.1756, 39.9560) in EPSG:4326.
  This is a manually defined envelope since no campus shapefile is loaded;
  see README for discussion.
*/

with penn_campus as (
    select st_makeenvelope(-75.2010, 39.9430, -75.1756, 39.9560, 4326)::geography as geog
)

select count(*) as count_block_groups
from census.blockgroups_2020 as bg, penn_campus as pc
where st_contains(pc.geog::geometry, bg.geog::geometry)
