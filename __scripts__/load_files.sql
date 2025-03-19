--in cmd run:--
cd "C:\Users\Xian Lu Lee\OneDrive - PennO365\Datasets\GeoCloud\musa-geocloud-assm02\data"
psql -U postgres
--PASSWORD IS USUAL PASSWORD--
createdb -port 5432 assignment2
--conect to db--
psql -h localhost -p 5432 -U postgres -d assignment2;

--CREATE TABLES THEN LOAD DATA--
\copy septa.bus_stops(stop_id,stop_name,stop_lat,stop_lon,location_type,parent_station,zone_id,wheelchair_boarding) FROM 'C:/Users/Xian Lu Lee/OneDrive - PennO365/Datasets/GeoCloud/musa-geocloud-assm02/data/stops.txt' WITH  CSV HEADER DELIMITER ',' ;

\copy septa.bus_routes(route_id,route_short_name,route_long_name,route_type,route_color,route_text_color,route_url) FROM 'C:/Users/Xian Lu Lee/OneDrive - PennO365/Datasets/GeoCloud/musa-geocloud-assm02/data/routes.txt' WITH  CSV HEADER;

\copy septa.bus_trips (route_id,service_id,trip_id,trip_headsign,block_id,direction_id,shape_id) FROM 'C:/Users/Xian Lu Lee/OneDrive - PennO365/Datasets/GeoCloud/musa-geocloud-assm02/data/trips.txt' WITH  CSV HEADER;

\copy septa.bus_shapes (stop_id,stop_name,stop_desc,stop_lat,stop_lon,zone_id,stop_url)FROM 'C:/Users/Xian Lu Lee/OneDrive - PennO365/Datasets/GeoCloud/musa-geocloud-assm02/data/shapes.txt' WITH  CSV HEADER;

\copy septa.rail_stops (stop_id,stop_name,stop_desc,stop_lat,stop_lon,zone_id,stop_url) FROM 'C:/Users/Xian Lu Lee/OneDrive - PennO365/Datasets/GeoCloud/musa-geocloud-assm02/data/stops_rail.txt' WITH  CSV HEADER;

\copy census.population_2020 (geoid,geoname,total) FROM 'C:/Users/Xian Lu Lee/OneDrive - PennO365/Datasets/GeoCloud/musa-geocloud-assm02/data/pop2020.csv' WITH  CSV HEADER ;



ogr2ogr -f "PostgreSQL" PG:"host=localhost port=5432 dbname=assignment2 user=postgres password=Xllxl@ntihacker7" "C:\Users\Xian Lu Lee\OneDrive - PennO365\Datasets\GeoCloud\musa-geocloud-assm02\data\PWD_PARCELS.geojson" -nln "phl.pwd_parcels" -nlt MULTIPOLYGON -t_srs EPSG:4326 -lco GEOMETRY_NAME=geog -lco GEOM_TYPE=GEOGRAPHY


ogr2ogr -f "PostgreSQL" PG:"host=localhost port=5432 dbname=assignment2 user=postgres password=Xllxl@ntihacker7" "C:\Users\Xian Lu Lee\OneDrive - PennO365\Datasets\GeoCloud\musa-geocloud-assm02\data\philadelphia-neighborhoods.geojson" -nln "phl.neighborhoods" -nlt MULTIPOLYGON -t_srs EPSG:4326 -lco GEOMETRY_NAME=geog -lco GEOM_TYPE=GEOGRAPHY

ogr2ogr -f "PostgreSQL" PG:"host=localhost port=5432 dbname=assignment2 user=postgres password=Xllxl@ntihacker7" "C:\Users\Xian Lu Lee\OneDrive - PennO365\Datasets\GeoCloud\musa-geocloud-assm02\data\tl_2020_42_bg.shp" -nln "census.blockgroups_2020" -nlt MULTIPOLYGON -t_srs EPSG:4326 -lco GEOMETRY_NAME=geog -lco GEOM_TYPE=GEOGRAPHY