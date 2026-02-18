
# get the campus boundary of University of Pennsylvania using OSMnx and save it as a geojson file
import osmnx as ox
ox.settings.use_cache=True
ox.settings.timeout=180
gdf = ox.geocode_to_gdf('University of Pennsylvania, Philadelphia, USA')
print(gdf)
gdf.to_file('penncampus.geojson', driver='GeoJSON')
print("successfully saved!")


# Test code to read the geojson file and plot the campus boundary
import geopandas as gpd
import matplotlib.pyplot as plt
gdf = gpd.read_file("penncampus.geojson")
gdf.plot(figsize=(6,6))
plt.title("University of Pennsylvania Campus Boundary")
plt.axis("off")
plt.show()