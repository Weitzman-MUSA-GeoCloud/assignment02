 

 
Query 5: Neighborhood Wheelchair Accessibility:  

Methodology 

To rate wheelchair accessibility, I ranked neighborhoods by the share of weekly bus service that occurs at accessible stops. I thought this metric was useful because I wanted to score accessibility based on the amount of service rather than just its presence. For example, two neighborhoods could have the same number of accessible stops, but the one with more frequent service will rank higher. The calculation I used was accessibility metric = accessible visits / (accessible visits + inaccessible visits).  

Stops with wheelchair boarding = 1 are counted as accessible; stops with wheelchair boarding = 2 are counted as inaccessible. Stops with unknown accessibility (value 0) and neighborhoods with no service in either category are excluded. The result is a value between 0 and 1, where 1 means every weekly bus stop visit in the neighborhood happens at a wheelchair-accessible stop, and 0 means none do. 

One neighborhood, Mechanicsville, was excluded from the analysis because no SEPTA bus stops fall within its boundaries. The final analysis therefore covers 158 of the 159 neighborhoods in the OpenDataPhilly dataset. 

Top 5 and Lowest 5 neighborhoods 

The top five neighborhoods tied with a 1.0 score for the accessibility metric included Olney, Somerton, Bustleton, Mayfair, and Oxford Circle. All of these neighborhoods are located in Northeast Philadelphia. The number of accessible stops ranged from 171 to 139 stops. Many neighborhoods also had a score of 1.0; however, the number of stops determined the top five. This also indicates that these five neighborhoods have not only fully accessible bus service, but also some of the highest service density in the city.  

The lowest five neighborhoods were Paschall, Southwest Schuylkill, Cedar Park, Woodland Terrace, and Bartram Village. The accessibility metric ranged from 0.36 to 0. These stops are concentrated in West and Southwest Philadelphia. Bartram Village stands out as the least accessible, with zero wheelchair-accessible stops out of 14, meaning none of its weekly bus service occurs at accessible stops.  

 

 
Query 6: Penn Campus Census Block group(s) Selection: 

To define Penn's campus, I used the Stormwater Billing Parcels dataset. This dataset clearly identifies parcels by ownership and was simpler to use than adding an external campus boundary file. I filtered to parcels owned by the Trustees of the University of Pennsylvania, then narrowed further to parcels within 800 meters of Meyerson Hall (220-30 S 34th St), which sits at the heart of campus. This second filter helped exclude scattered Penn-owned properties elsewhere in the city, such as off-campus housing or research facilities. I then took the convex hull of the union of those parcels to create a single contiguous campus boundary and counted the number of census block groups fully contained within it. 