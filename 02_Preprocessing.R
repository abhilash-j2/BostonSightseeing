
# Performing preprocessing

combinedTable <- readRDS("combinedTable.rds")

library(readxl)
distmat_df <- read_excel("DistanceMatrix.xlsx",sheet = 1)

distmat <- as.matrix(distmat_df[,-c(1,2)])
rownames(distmat) <- distmat_df$Symbol

library(dplyr)
library(tidyr)
neu <- combinedTable[1,]
neu[,] <- NA
neu$name <- "Home_NEU"
neu$name_symbol <- "Home_NEU"
neu$Fare <- 0
neu$weighted_Rating <- 0
neu$loc_lat <- 42.3398
neu$loc_long <- -71.0892
neu$duration <- "0"

neu_start <- neu %>% mutate(name_symbol = "HOME_NEU_START")
neu_end <- neu %>% mutate(name_symbol = "HOME_NEU_END")

# Calculating lat long
radius <- 6371e3
#var φ1 = lat1.toRadians();
#var φ2 = lat2.toRadians();
#var Δφ = (lat2-lat1).toRadians();
#var Δλ = (lon2-lon1).toRadians();

# var a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
#  Math.cos(φ1) * Math.cos(φ2) *
#  Math.sin(Δλ/2) * Math.sin(Δλ/2);
# var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
# var d = R * c;

rad2deg <- function(rad) {(rad * 180) / (pi)}
deg2rad <- function(deg) {(deg * pi) / (180)}

lat1 = 42.355671	
long1 = -71.062759
lat2 = 42.34853	
long2 = -71.0951

phi1 = deg2rad(lat1)
phi2 = deg2rad(lat2)
delta_phi = deg2rad(lat2-lat1)
delta_lambda = deg2rad(long2 - long1)

ac <- sin(delta_phi/2)*sin(delta_phi/2) + cos(phi1)*cos(phi2)*sin(delta_lambda/2)*sin(delta_lambda/2)
radius*2*atan2(sqrt(ac), sqrt(1-ac))



calc_haversine_dist <- function(lat1, long1, lat2, long2, resultUnits = ""){
  kmTomilesFactor <- 0.621371
  distance = acos( sin(deg2rad(lat1))*sin(deg2rad(lat2)) + 
                     cos(deg2rad(lat1))*cos(deg2rad(lat2))*cos(deg2rad(long2-long1)) 
  ) * 6371
  # In Km
  if(resultUnits == "km"){
    retun(distance)
  } else {
    return(distance*kmTomilesFactor)
  }
}

# reducing the data to only 30 places
a <- distmat
distmat[lower.tri(distmat)] <- t(distmat)[lower.tri(t(distmat))]
top30rating <- combinedTable$name_symbol[order(-combinedTable$weighted_Rating)[1:50]]

top30reviews <- combinedTable$name_symbol[order(-combinedTable$reviews)[1:50]]


# > top30rating
# [1] "LttBIaL" "AnaHACM" "ThBstnP" "NwEnCJH" "MsmofFA" "ArnldAr" "DwnstCH" "MFABstn" "ThPOoEG" "BstnBll" "BstnWnr" "MtrplWM" "FrtWrrn" "FnwyPrk"
# [15] "SmlAdmB" "BstnPbL" "EmrldNc" "BstnPbG" "BackBay" "Mrrt_CH" "EtDaMGH" "ThmpsnI" "NrthEnd" "PirsPrk" "NwEngHM" "BstnAth" "ArlngSC" "JhFKPML"
# [29] "BstnOpH" "CmmnwAM"

intersect(top30rating, top30reviews)

# small_combined <- combinedTable[which(combinedTable$name_symbol %in% top30rating),]
small_combined <- combinedTable
small_combined <- small_combined[-which(small_combined$name == "MFA Boston"),]
small_combined <- bind_rows(neu_start,neu_end,small_combined)

combos <- expand.grid(one= small_combined$name_symbol, two = small_combined$name_symbol,
                      KEEP.OUT.ATTRS = T,stringsAsFactors = F)
combos$lat1 <- small_combined$loc_lat[match(table=small_combined$name_symbol,combos$one)]
combos$long1 <- small_combined$loc_long[match(table=small_combined$name_symbol,combos$one)]
combos$lat2 <- small_combined$loc_lat[match(table=small_combined$name_symbol,combos$two)]
combos$long2 <- small_combined$loc_long[match(table=small_combined$name_symbol,combos$two)]

combos$distance <- round(calc_haversine_dist(combos$lat1, combos$long1, combos$lat2, combos$long2), digits = 4)
combos$distance <- ifelse(is.na(combos$distance), 0, combos$distance)
combos$distance <- ifelse(combos$one == combos$two, 0, combos$distance)
combos$time_hrs_at_25mph <- combos$distance / 25
combos$travel_time_at_1.5x <- round(combos$time_hrs_at_25mph * 1.5,digits = 2)
combos$travel_time_at_1.75x <- round(combos$time_hrs_at_25mph * 1.75,digits = 2)

library(tidyr)
dist_out <- combos %>% select(one, two, distance) %>% spread(two, distance)

durationMap <- data.frame(duration = c("More than 3 hours", "2-3 hours", "1-2 hours", "< 1 hour", 0, NA),
                          values = c(3.5, 3, 2, 0.75, 0, 1))

dist_out <- dist_out[match(small_combined$name_symbol,dist_out$one), c("one",small_combined$name_symbol)]
# write.csv(dist_out, "small_dist_miles.csv",row.names = F)
write.csv(dist_out, "small_dist_miles_v4.csv",row.names = F)
#write.csv(dist_out, "complete_dist_miles_v5.csv",row.names = F)
write.csv(dist_out, "intermediate_dist_miles_v5.csv",row.names = F)

small_combined$FareCorrected <- ifelse(is.na(small_combined$Fare), 0, small_combined$Fare)
small_combined$duration_numeric <- durationMap$values[match(small_combined$duration, durationMap$duration)]

small_combined %>% 
  select(name_symbol, FareCorrected, duration_numeric, weighted_Rating) %>%
  write.csv(file = "intermediate_dat_file_v5.csv",row.names = F)


write.csv(file = "complete_dat_file_v5.csv",row.names = F)

smallDist <- distmat[rownames(distmat) %in% top30, colnames(distmat) %in% top30]
small_combined <- combinedTable[which(combinedTable$name_symbol %in% top30),]



library(xlsx)
write.xlsx2(distmat,"Full_distance_matrix.xlsx")

# Making the Fares that are missing to be 0
small_combined$Fare <- ifelse(is.na(small_combined$Fare), 0, small_combined$Fare)




# Creating 



max(small_combined$duration,na.rm = T)





