# Renamed the 3 columns to be src, dst, value

links <- read.delim("Optimization/travelled.tab",skip = 1,col.names = c("src","dst","travel"))
# View(links)
links_matched <- subset(links, travel == 1)
library(igraph)
net <- graph_from_edgelist(as.matrix(links_matched[,1:2]))
plot(net)

##
# install.packages("sf")
library(sf)
# install.packages("mapview")

library(mapview)

locations_sf <- st_as_sf(small_combined[,c("name","loc_long","loc_lat")], coords = c("loc_long", "loc_lat"), crs = 4326)
mapview(locations_sf)

locations_sf <- st_as_sf(combinedTable[,c("name","loc_long","loc_lat")], coords = c("loc_long", "loc_lat"), crs = 4326)
mapview(locations_sf)
