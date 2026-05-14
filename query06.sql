with bus_nbhds as (
    select
        stps.stop_id,
        stps.stop_name,
        stps.wheelchair_boarding,
        nbhd.listname
    from septa.bus_stops as stps
    inner join phl.neighborhoods as nbhd
        on
            st_dwithin(stps.geog, nbhd.geog, 50)
)

select
    listname as neighborhood_name_text,
    round(
        (
            (
                count(*) filter (where wheelchair_boarding = 1)
                - avg(count(*) filter (where wheelchair_boarding = 1)) over ()
            )::FLOAT
            / nullif(
                stddev_pop(count(*) filter (where wheelchair_boarding = 1)) over (),
                0
            )
        )::NUMERIC,
        2
    ) as accessibility_metric,
    count(*) filter (where wheelchair_boarding = 1) as num_bus_stops_accessible,
    count(*) filter (where wheelchair_boarding = 2 or wheelchair_boarding = 0) as num_bus_stops_inaccessible
from bus_nbhds
group by listname
order by accessibility_metric desc
limit 5;
