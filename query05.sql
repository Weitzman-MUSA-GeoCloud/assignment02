/*
Rate neighborhoods by their bus stop accessibility for wheelchairs.
Use OpenDataPhilly's neighborhood dataset along with an appropriate dataset from the Septa GTFS bus feed.
Use the [GTFS documentation](https://gtfs.org/reference/static/) for help.
Use some creativity in the metric you devise in rating neighborhoods.
*/

with

ngh_area as(
select 
		name,
        shape_area, 
        st_area(geog) / 1000000 as area_sqkm,
        geog
    from phl.neighborhoods as ngh
)

select
	name AS neighborhood_name,
	SUM(CASE WHEN stops.wheelchair_boarding = 1 THEN 1 ELSE 0 END) / ngh_area.area_sqkm AS accessibility_metric, --Density of accessible bus_stops
	SUM(CASE WHEN stops.wheelchair_boarding = 1 THEN 1 ELSE 0 END) AS num_bus_stops_accessible, -- Number of accessible bus stops
    SUM(CASE WHEN stops.wheelchair_boarding != 1 THEN 1 ELSE 0 END) AS num_bus_stops_inaccessible -- Number of inaccessible bus stops
FROM ngh_area
JOIN septa.bus_stops as stops
  ON ST_Within(stops.geog::geometry, ngh_area.geog::geometry)
GROUP BY ngh_area.name, ngh_area.area_sqkm