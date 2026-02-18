/*
With a query, find out how many census block groups Penn's main campus
fully contains. Discuss which dataset you chose for defining Penn's campus.
Structure (should be a single value):
*/

SELECT COUNT(census.blockgroups_2020.geoid)::integer AS count_block_groups
FROM
    census.blockgroups_2020
INNER JOIN phl.penn_campus
    ON public.ST_CoveredBy(
        census.blockgroups_2020.geog,
        phl.penn_campus.geog
    );

/*
Dataset: OpenStreetMap (OSM) - University of Pennsylvania campus boundary
Method: 使用Python脚本通过Overpass API查询OSM数据，筛选出Penn主校区边界
(relation/way tags: name="University of Pennsylvania")，导出为GeoJSON格式。
使用ogr2ogr将数据加载为phl.penn_campus表（GEOGRAPHY类型，EPSG:4326）。
Query logic: ST_Contains确保只统计完全位于Penn校区内的block groups。
*/
