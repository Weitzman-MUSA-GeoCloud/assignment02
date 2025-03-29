library(sf)
library(tidyverse)
library(ggplot2)
bg <- st_read("C:/Users/19397/Documents/GitHub/MUSA_509/musa509_assignment02/data/tl_2020_42_bg")
bg_transform <- bg %>%
  st_transform('EPSG:4326')
st_write(bg_transform, "C:/Users/19397/Documents/GitHub/MUSA_509/musa509_assignment02/data/bg_transformed.geojson",
         driver = "geojson")

pwd <- st_read("C:/Users/19397/Documents/GitHub/MUSA_509/musa509_assignment02/data/PWD_PARCELS.geojson")
pwd_transformed <- pwd %>%
  st_transform('EPSG:4326')
st_write(pwd_transformed, "C:/Users/19397/Documents/GitHub/MUSA_509/musa509_assignment02/data/PWD_PARCELS_transformed.geojson",
         driver = "geojson")

new_bg <- st_read("~/GitHub/MUSA_509/musa509_assignment02/data/bg_transformed.geojson")
st_crs(new_bg)
ggplot(new_bg) +
  geom_sf(color = "black", fill = "transparent") +
  theme_void()

upenn <- st_read("~/GitHub/MUSA_509/musa509_assignment02/data/upenn-extent-32129-100mbuffer-dissolved.geojson")
st_crs(upenn)
upenn_transformed <- upenn %>%
  st_transform('EPSG:4326')
ggplot(upenn_transformed) +
  geom_sf(color = "black", fill = "transparent") +
  theme_void()
st_write(upenn_transformed, "~/GitHub/MUSA_509/musa509_assignment02/data/upenn_transformed.geojson",
         driver = "geojson")

rail_lines <- st_read("~/GitHub/MUSA_509/musa509_assignment02/data/Regional_Rail_Lines.geojson")
st_crs(rail_lines)