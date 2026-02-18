alter table septa.bus_stops
    add column if not exists geog geography;

update septa.bus_stops
set geog = st_setsrid(st_makepoint(stop_lon, stop_lat), 4326)::geography;

create index if not exists idx_bus_stops_geog
    on septa.bus_stops using gist (geog);