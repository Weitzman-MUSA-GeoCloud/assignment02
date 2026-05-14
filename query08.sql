/*
  How many census block groups does Penn's main campus fully contain?
  Penn's campus is defined using the "University City" neighborhood from
  phl.neighborhoods (see README discussion).
*/

select count(*)::integer as count_block_groups
from census.blockgroups_2020 as bg
where public.st_within(
    bg.geog::public.geometry,
    (select geog::public.geometry from phl.neighborhoods where listname = 'University City' limit 1)
)
