# Renamed the 3 columns to be src, dst, value

links <- read.delim("Optimization/travelled.tab",skip = 1,col.names = c("src","dst","days","travel"))
# View(links)
links_matched <- subset(links, travel == 1)
library(igraph)
net <- graph_from_edgelist(as.matrix(links_matched[,1:2]))
plot(net)

path_list <- all_simple_paths(graph = net, from = "HOME_NEU_START",to = "HOME_NEU_END")


path_output <- lapply(path_list, function(pl){
          places <- attr(pl,"names")
          dat <- small_combined[match(places, table = small_combined$name_symbol), 
                                c("name","name_symbol","loc_long","loc_lat")]
          return(dat)
        })



a <- st_as_sf(path_output[[1]], coords = c("loc_long", "loc_lat"), crs = 4326)
linestrings <- lapply(X = 1:(nrow(a)-1), FUN = function(x) {
  
  pair <- st_combine(c(a$geometry[x], a$geometry[x + 1]))
  line <- st_cast(pair, "LINESTRING")
  return(line)
  
})
multilinetring <- st_multilinestring(do.call("rbind", linestrings))

library(visNetwork)

nn <-  toVisNetworkData(net)
nn$edges$arrows <- "to"

nn$edges$color <- palette(rainbow(length(unique(nn$edges$days))))[nn$edges$days]

visNetwork(nodes = nn$nodes, edges = nn$edges)

##
# install.packages("sf")
library(sf)
# install.packages("mapview")

library(mapview)

locations_sf <- st_as_sf(small_combined[,c("name","loc_long","loc_lat")], coords = c("loc_long", "loc_lat"), crs = 4326)
mapview(locations_sf)

locations_sf <- st_as_sf(combinedTable[,c("name","loc_long","loc_lat")], coords = c("loc_long", "loc_lat"), crs = 4326)
mapview(locations_sf,legend = F)
