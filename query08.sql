/*
  With a query, find out how many census block groups Penn's main campus fully
  contains.

  I used the Philadelphia Water Department Stormwater Billing Parcels dataset
  (phl.pwd_parcels) to define Penn's campus boundary. The campus is defined as
  the union of all parcels owned by the University of Pennsylvania (where the
  owner1 field contains 'UNIVERSITY OF PENNSYLVANIA'). This dataset was chosen
  because it provides parcel-level ownership data for all of Philadelphia,
  allowing precise identification of Penn-owned properties that collectively
  form the main campus footprint.
*/

select
    count(*) as count_block_groups
from census.blockgroups_2020 as bg
where st_within(
    bg.geog::geometry,
    (
        select st_union(geog::geometry)
        from phl.pwd_parcels
        where upper(owner1) like '%UNIVERSITY OF PENNSYLVANIA%'
    )
)
