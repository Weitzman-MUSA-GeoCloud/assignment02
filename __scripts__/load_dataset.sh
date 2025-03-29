# phl.pwd_parcels
ogr2ogr `
  -of "PostgreSQL" `
  -nln phl.pwd_parcels `
  -nlt MULTIPOLYGON `
  -lco "OVERWRITE=yes" `
  -lco "GEOM_TYPE=geography" `
  -lco "GEOMETRY_NAME=geog" `
  PG:"host=localhost port=5432 dbname=assign02 user=postgres password=010820" `
  "musa509_assignment02/data/PWD_PARCELS_transformed.geojson"

# phl.neighborhoods
ogr2ogr `
  -of "PostgreSQL" `
  -nln phl.neighborhoods `
  -nlt MULTIPOLYGON `
  -lco "OVERWRITE=yes" `
  -lco "GEOM_TYPE=geography" `
  -lco "GEOMETRY_NAME=geog" `
  PG:"host=localhost port=5432 dbname=assign02 user=postgres password=010820" `
  "musa509_assignment02/data/philadelphia-neighborhoods.geojson"

# census.blockgroups_2020
ogr2ogr `
  -of "PostgreSQL" `
  -nln census.blockgroups_2020 `
  -nlt MULTIPOLYGON `
  -lco "OVERWRITE=yes" `
  -lco "GEOM_TYPE=geography" `
  -lco "GEOMETRY_NAME=geog" `
  PG:"host=localhost port=5432 dbname=assign02 user=postgres password=010820" `
  "data\bg_transformed.geojson"

-t_srs EPSG:4326
"+proj=longlat +datum=WGS84 +no_defs" `
# census.population_2020
cat .\musa509_assignment02\data\DECENNIALPL2020.P1-Data.csv | csvcut --columns 1-3 > .\musa509_assignment02\data\population2020.csv

# phl.upenn
ogr2ogr `
  -of "PostgreSQL" `
  -nln phl.upenn `
  -nlt MULTIPOLYGON `
  -lco "OVERWRITE=yes" `
  -lco "GEOM_TYPE=geography" `
  -lco "GEOMETRY_NAME=geog" `
  PG:"host=localhost port=5432 dbname=assign02 user=postgres password=010820" `
  "data/upenn_transformed.geojson"

# septa.rail_lines
ogr2ogr `
  -of "PostgreSQL" `
  -nln septa.rail_lines `
  -lco "OVERWRITE=yes" `
  -lco "GEOM_TYPE=geography" `
  -lco "GEOMETRY_NAME=geog" `
  PG:"host=localhost port=5432 dbname=assign02 user=postgres password=010820" `
  "data/Regional_Rail_Lines.geojson"