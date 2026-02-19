/*
  With a query, find out how many census block groups Penn's main campus
  fully contains. Discuss which dataset you chose for defining Penn's campus.

  Structure (should be a single value):

  (
    count_block_groups integer
  )

  Discussion: I chose to use the PWD parcels dataset to define Penn's main
  campus and filtered the parcels to include only those owned by entities
  that are likely associated with Penn, such as "TRS UNIV OF PENN", "TRUSTEES",
  "UNIVERSITY", and "U OF P" when I was looking at their interactive map. I
  also excluded parcels that are likely associated with other universities,
  such as "DREXEL" and "TEMPLE". By using the st_contains function, I was
  able to determine which census block groups are fully contained within the
  geographic boundaries of the selected parcels.
*/

select count(bg.geoid) as count_block_groups
from
    census.blockgroups_2020 as bg
inner join
    phl.pwd_parcels as parcels
    on st_contains(
        bg.geog::geometry,
        parcels.geog::geometry
    )
where (
        parcels.owner1 like 'TRS UNIV OF PENN'
        or parcels.owner1 like 'TRUSTEES'
        or parcels.owner1 like 'UNIVERSITY'
        or parcels.owner1 like 'U OF P'
    )
    and parcels.owner1 not like 'DREXEL'
    and parcels.owner1 not like 'TEMPLE'
