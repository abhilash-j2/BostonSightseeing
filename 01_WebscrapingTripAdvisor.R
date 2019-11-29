

library(rvest)
walk_Pg1 <- read_html("https://www.tripadvisor.com/Attraction_Products-g60745-zfc12046-zfg11876-Boston_Massachusetts.html")
walk_Pg2 <- read_html("https://www.tripadvisor.com/Attraction_Products-g60745-oa30-a_sort.-zfc12046-zfg11876-Boston_Massachusetts.html#ATTRACTION_LIST")
walk_Pg3 <- read_html("https://www.tripadvisor.com/Attraction_Products-g60745-oa60-a_sort.-zfc12046-zfg11876-Boston_Massachusetts.html#ATTRACTION_LIST")

listing <- html_nodes(walk, ".attraction_clarity_cell")
html_text(attactions)

listing2 <- html_nodes(walk_Pg2, ".attraction_clarity_cell")
listing3 <- html_nodes(walk_Pg3, ".attraction_clarity_cell")

 

# listing_df <-data.frame(title= html_nodes(listing, ".listing_title") %>% html_text() )
# listing_df$reviews <- html_nodes(listing, ".rating") %>% html_text()


fillNA <- function(vec){
  return(ifelse(length(vec) > 0, vec, NA))
}


readListingCard <- function(card){
  
  title <- html_nodes(card, ".listing_title") %>% html_text()
  reviews <- html_nodes(card, ".rating") %>% html_text()
  rating <- html_nodes(card, ".ui_bubble_rating") %>% html_attr("alt")
  price <- html_nodes(card, ".from") %>% html_nodes("span") %>% html_text()
  duration <- html_nodes(card, ".product_duration") %>% html_text()
  listing_url <- html_nodes(card, ".listing_title") %>% html_node("a") %>% html_attr("href")
  result_list <- list(title= title,
              rating = rating,
              reviews= reviews,
              price = price,
              duration = duration,
              listing_url = listing_url)
  return(lapply(result_list, fillNA))
}


listing_df <- bind_rows(bind_rows(lapply(listing, readListingCard)) ,
                        bind_rows(lapply(listing2, readListingCard)),
                        bind_rows(lapply(listing3, readListingCard)))


fenway <- read_html("https://www.tripadvisor.com/Attraction_Products-g60745-d105250-Fenway_Park-Boston_Massachusetts.html") %>%
  html_nodes(".attraction_clarity_cell") %>% lapply(readListingCard) %>% bind_rows()

# Testing out the  

# Things to do list
thingsToDo <- read_html("https://www.tripadvisor.com/Attractions-g60745-Activities-Boston_Massachusetts.html")

# Lisiting container
thingsToDo %>% html_nodes(".attractions-attraction-overview-pois-PoiCard__item--3UzYK") 
# Listing Category
thingsToDo %>% html_nodes(".attractions-category-tag-CategoryTag__category_tag--3_ylb") %>% html_text()
# Listing Name
thingsToDo %>% html_nodes(".attractions-attraction-overview-pois-PoiCard__item--3UzYK") %>% 
  html_nodes(".attractions-attraction-overview-pois-PoiInfo__name--SJ0a4") %>% html_text()
# URL
thingsToDo %>% html_nodes(".attractions-attraction-overview-pois-PoiCard__item--3UzYK") %>% 
  html_nodes(".attractions-attraction-overview-pois-PoiInfo__name--SJ0a4") %>% html_attr("href")
# Rating
thingsToDo %>% html_nodes(".ui_bubble_rating") %>% html_attr("class") %>% substr(start = nchar(.) -1, nchar(.)) 
# Reviews 
thingsToDo %>% html_nodes(".reviewCount") %>% html_text()



ttd01 <- "https://www.tripadvisor.com/Attractions-g60745-Activities-Boston_Massachusetts.html"
ttd02 <- "https://www.tripadvisor.com/Attractions-g60745-Activities-oa30-Boston_Massachusetts.html"
ttd03 <- "https://www.tripadvisor.com/Attractions-g60745-Activities-oa60-Boston_Massachusetts.html"
ttd04 <- "https://www.tripadvisor.com/Attractions-g60745-Activities-oa90-Boston_Massachusetts.html"
ttd05 <- "https://www.tripadvisor.com/Attractions-g60745-Activities-oa120-Boston_Massachusetts.html"
ttd06 <- "https://www.tripadvisor.com/Attractions-g60745-Activities-oa150-Boston_Massachusetts.html"
ttd07 <- "https://www.tripadvisor.com/Attractions-g60745-Activities-oa180-Boston_Massachusetts.html"
ttd08 <- "https://www.tripadvisor.com/Attractions-g60745-Activities-oa210-Boston_Massachusetts.html"
ttd09 <- "https://www.tripadvisor.com/Attractions-g60745-Activities-oa240-Boston_Massachusetts.html"
ttd10 <- "https://www.tripadvisor.com/Attractions-g60745-Activities-oa270-Boston_Massachusetts.html"
ttd11 <- "https://www.tripadvisor.com/Attractions-g60745-Activities-oa300-Boston_Massachusetts.html"
ttd12 <- "https://www.tripadvisor.com/Attractions-g60745-Activities-oa330-Boston_Massachusetts.html"

# paste(c(paste0("ttd0",1:9),paste0("ttd",10:12)),collapse = ", ")
ttd_list <-eval(parse(text=paste("list(",
                                   paste(c(paste0("ttd0",1:9),paste0("ttd",10:12)),collapse = ", "),
                                   ")")
                      ))


readActivityCard_pg1 <- function(card){
   
  # Listing Category
  categ <- card %>% html_nodes(".attractions-category-tag-CategoryTag__category_tag--3_ylb") %>% html_text()
  # Listing Name
  lname <- card %>% html_nodes(".attractions-attraction-overview-pois-PoiInfo__name--SJ0a4") %>% html_text()
  # URL
  lurl <- card %>%  html_nodes(".attractions-attraction-overview-pois-PoiInfo__name--SJ0a4") %>% html_attr("href")
  # Rating
  rating <- card %>% html_nodes(".ui_bubble_rating") %>% html_attr("class") %>% substr(start = nchar(.) -1, nchar(.)) 
  # Reviews 
  reviews <- card %>% html_nodes(".reviewCount") %>% html_text()
  
  result <- list(name = lname, 
             category = categ, 
             url = lurl, 
             rating = rating,
             reviews = reviews)
  result <- lapply(result, fillNA)
  
}


readActivityCard_other <- function(card){
  
  # Listing Category
  categ <- card %>% html_nodes(".matchedTag") %>% html_text()
  # Listing Name
  lname <- card %>% html_nodes(".listing_title")  %>% html_node("a") %>% html_text()
  # URL
  lurl <- card %>%  html_nodes(".listing_title") %>% html_node("a") %>% html_attr("href")
  # Rating
  rating <- card %>% html_nodes(".ui_bubble_rating") %>% html_attr("class") %>% substr(start = nchar(.) -1, nchar(.)) 
  # Reviews 
  reviews <- card %>% html_nodes(".more") %>% html_node("a") %>% html_text()
  
  result <- list(name = lname, 
                 category = categ, 
                 url = lurl, 
                 rating = rating,
                 reviews = reviews)
  result <- lapply(result, fillNA)
  
}

result_list <- list()
counter <- 1

for (link in ttd_list){
  thingsToDo <- read_html(unlist(link))
    # Lisiting container
  if(counter == 1){
    cards <- thingsToDo %>% html_nodes(".attractions-attraction-overview-pois-PoiCard__item--3UzYK")
    result <- lapply(cards, readActivityCard_pg1) %>% bind_rows()  
  } else {
    cards <- thingsToDo %>% html_nodes(".listing_info")
    result <- lapply(cards, readActivityCard_other) %>% bind_rows()
  }
  
  result$src_url <- unlist(link)
  result_list <- append(result_list, list(result))
  print(paste(counter,"parsed :", unlist(link)))
  counter = counter + 1
  Sys.sleep(sample(4:6))
}


dd2 <- bind_rows(result_list)


### SCRAPING DETAILED LISTING 

dd2 <- read.csv("ThingsToDoList.csv",stringsAsFactors = F)


dd2$url


getPageDetails <- function(page_url){
  detailPage <- read_html(page_url)
  # Name
  name <- detailPage %>% html_nodes("#HEADING") %>% html_text()
  # Address
  address <- detailPage %>% html_nodes(".detail_section.address") %>% html_text()
  # Duration 
  # detailPage %>% html_nodes(xpath = "//*[@class='attractions-attraction-detail-about-card-AboutSection__sectionWrapper--3PMQg']") %>% html_text()
  about <- detailPage %>% html_nodes(".attractions-attraction-detail-about-card-AboutSection__sectionWrapper--3PMQg")
  durationFlag <- about %>% html_text() %>% grepl(pattern = "duration")
  duration <- about[durationFlag] %>% html_text()
  timeslots <- about %>% html_nodes(".clock + div") %>% html_text()
  
  timeslot2 <- detailPage %>% html_nodes(".openHoursInfo") %>% html_text()
  
  result <- list(name = name, 
                 address = address, 
                 duration = duration,
                 timeslots = timeslots,
                 timeslot2 = timeslot2)
  
  
}

detailPage <- read_html(dd2$url[2])
# Name
detailPage %>% html_nodes("#HEADING") %>% html_text()
# Address
detailPage %>% html_nodes(".detail_section.address") %>% html_text()
# Duration 
# detailPage %>% html_nodes(xpath = "//*[@class='attractions-attraction-detail-about-card-AboutSection__sectionWrapper--3PMQg']") %>% html_text()
about <- detailPage %>% html_nodes(".attractions-attraction-detail-about-card-AboutSection__sectionWrapper--3PMQg")
durationFlag <- about %>% html_text() %>% grepl(pattern = "duration")
duration <- about[durationFlag] %>% html_text()
timeslots <- about %>% html_nodes(".clock + div") %>% html_text()

timeslot2 <- detailPage %>% html_nodes(".openHoursInfo") %>% html_text()
detailPage %>% html_nodes(".ppr_rup ppr_priv_location_detail_contact_card")


returnLink <- "https://www.tripadvisor.com/Attractions-g60745-Activities-Boston_Massachusetts.html"

# library(RSelenium)
# rD <- rsDriver(browser=c("firefox"))
# driver <- rD$client
  driver$open()
# pg <- (dd2$url[2])
# driver$navigate(pg)

  detailed_result_list <- list()
  
for (url in dd2$url[18:150]){
    t0 <- Sys.time()
    driver$navigate(url)
    t1 <- Sys.time()
    Sys.sleep(max(c(2, 10*as.numeric(t1-t0))))
    el <- driver$findElement(using = "css","#HEADING")
    name <- el$getElementText()[[1]]
    el <- driver$findElement("css", "body")
    el$sendKeysToElement(list(key = "page_down"))
    Sys.sleep(1)
    mapinfo <- NA
    tryCatch({
      el <- driver$findElement(using = "css",".mapImg")
      mapinfo <- el$getElementAttribute("src")[[1]]  
    }, error= function(e){
      print("map failed to load")
    })
    
    el <- driver$findElement(using = "css", ".detail_section.address")
    address <- el$getElementText()[[1]]
    tryCatch({
      el <- driver$findElement(using="css", ".public-location-hours-LocationHours__hoursLink--2wAQh")
      # Simulate click on the open hours 
      el$clickElement()
      Sys.sleep(2)
      el <- driver$findElement(using="css", ".all-open-hours")
      timeslots <- el$getElementText()[[1]]  
    }, error= function(e){
      print(e)
      timeslots <<- NA
    })
    tryCatch({
      el <- driver$findElement(using="css", ".clock + div")
      timeslot2 <- el$getElementText()[[1]]  
    }, error=function(e){
      timeslot2 <<- NA
    })
    costs <- NA
    tryCatch({
      el <- driver$findElement(using="css", ".attractions-multi-tour-module-MultiTourModule__multi_tour_module--2l0GC")
      costs <- el$getElementText()[[1]]  
    }, error= function(e){
      tryCatch({
        el <- driver$findElement(using="css", ".attractions-multi-tour-ticket-TicketList__tickets_wrapper--32zIL")
        costs <- el$getElementText()[[1]]
      }, error = function(ee){
        print("double error")
      })
    })
    
    selenium_result <- list(url = url, 
                            name = name,
                            mapinfo = mapinfo,
                            address = address,
                            timeslots = timeslots,
                            timeslot2 = timeslot2,
                            costs = costs
    )
    selenium_result <- lapply(selenium_result, fillNA) 
    detailed_result_list <- append(detailed_result_list, list(selenium_result))
    Sys.sleep(2)
    driver$navigate(returnLink)
    Sys.sleep(3)
}
  
  
#  Extracting lat long information from the mapinfo url

a <- regexec("*AR_Anchor_pin\\.png\\|(\\-?\\d+\\.\\d+),(\\-?[0-9]+\\.[0-9]+)\\&\\&mark", rr$mapinfo)  
mm <-do.call("rbind",regmatches(rr$mapinfo, a))
rr$anchorpin_lat <- as.numeric(mm[,2])
rr$anchorpin_long <- as.numeric(mm[,3])

a <- regexec("*AR_pin\\.png\\|(\\-?\\d+\\.\\d+),(\\-?\\d+\\.\\d+)\\|(\\-?\\d+\\.\\d+),(\\-?\\d+\\.\\d+)", rr$mapinfo)  
mm <-do.call("rbind",regmatches(rr$mapinfo, a))
rr$loc_lat <- as.numeric(mm[,2])
rr$loc_long <- as.numeric(mm[,3])
rr$other_lat <- as.numeric(mm[,4])
rr$other_long <- as.numeric(mm[,5])

# Sanitising the name - removing symbols and abbreviating
x <- gsub(pattern = "\\'|\\,",replacement = "_",x = rr$name) %>% gsub(pattern="\\&|\\.|\\s\\-\\s",replacement = "")
rr$name_symbol <- abbreviate(x,minlength = 7)
# check unique 
length(unique(rr$name_symbol)) == nrow(rr)


rr$category <- dd2$category[1:150]
rr$reviews <- dd2$reviews[1:150]



  


driver$open()
# pg <- (dd2$url[2])
# driver$navigate(pg)

detailed_result_list2 <- list()

for (url in rr$url){
  t0 <- Sys.time()
  driver$navigate(url)
  t1 <- Sys.time()
  Sys.sleep(max(c(2, 10*as.numeric(t1-t0))))
  el <- driver$findElement(using = "css","#HEADING")
  name <- el$getElementText()[[1]]
  el <- driver$findElement("css", "body")
  el$sendKeysToElement(list(key = "page_down"))
  Sys.sleep(1)
  ratings <- NA
  tryCatch({
    el <- driver$findElement(using = "css",".ratings_chart")
    ratings <- el$getElementText()[[1]]  
  }, error= function(e){
    print("no rating")
  })
  duration <- NA
  tryCatch({
    el <- el <- driver$findElement(using="xpath", "//span[contains(@class,'duration')]/parent::div")
    # Simulate click on the open hours 
    Sys.sleep(2)
    duration <- el$getElementText()[[1]]  
  }, error= function(e){
    print(e)
  })
  
  costs <- NA
  tryCatch({
    el <- driver$findElement(using="css", ".attractions-multi-tour-ticket-TicketList__ticket_list--gAKF5")
    costs <- el$getElementText()[[1]]  
  }, error= function(e){
    tryCatch({
      el <- driver$findElement(using="css", ".attractions-multi-tour-ticket-Tours__tour_list_wrapper--3mLcb")
      costs <- el$getElementText()[[1]]
    }, error = function(ee){
      print("double error")
    })
  })
  
  selenium_result <- list(url = url, 
                          name = name,
                          ratings = ratings,
                          costs = costs,
                          duration = duration
  )
  selenium_result <- lapply(selenium_result, fillNA) 
  detailed_result_list2 <- append(detailed_result_list2, list(selenium_result))
  # Sys.sleep(2)
  # driver$navigate(returnLink)
  Sys.sleep(3)
}
rr2 <- bind_rows(detailed_result_list2)

rr2copy <- rr2
rr2copy$ratings <- gsub("\\%",replacement = "",rr2copy$ratings)
rr2copy <- separate(rr2copy,col = ratings, c(NA,"R05_Excellent", 
                                  NA, "R04_VeryGood", 
                                  NA, "R03_Average", 
                                  NA, "R02_Poor", 
                                  NA, "R01_Terrible"),sep = "\n",convert = T) 

rr2copy <- rr2copy %>% mutate(weighted_Rating = (5*R05_Excellent + 4*R04_VeryGood + 
                                                   3*R03_Average + 2*R02_Poor + 
                                                   1*R01_Terrible)/100)
rr2copy$duration <- gsub(pattern = "Suggested duration: ",replacement = "",rr2copy$duration)

rr$reviews <- rr$reviews %>% gsub(pattern=" reviews|,",replacement="") %>% as.numeric()





combinedTable <- cbind(rr, rr2copy[,c(-1,-2)])
names(combinedTable)[22] <- "cost_Alt"

combinedTable$combinedCosts <- ifelse(is.na(combinedTable$costs), 
       ifelse(is.na(combinedTable$cost_Alt), NA, combinedTable$cost_Alt),
       combinedTable$costs)

# combinedTable$Fare <- gregexpr("\\$\\d+\\.?\\d+?",text = combinedTable$combinedCosts) 
combinedTable$Fare <- gregexpr("(\\d+\\.\\d{1,2})",text = combinedTable$combinedCosts) %>% 
  regmatches(x=combinedTable$combinedCosts) %>%
  lapply(FUN = function(x){
    if(length(x)>0){
      y <- gsub(pattern="\\$",replacement="",x)
      y <- as.numeric(y)
      return(min(y))
    } else {
      return(NA)
    }
  }) %>% unlist

combinedTable$timeslots[12] <- combinedTable$timeslots[17]


combinedTableOutput <- combinedTable
combinedTableOutput <- combinedTableOutput[,c("url", "name", "mapinfo", "address", "timeslots", "anchorpin_lat", 
                                              "anchorpin_long", "loc_lat", "loc_long", "other_lat", "other_long", 
                                              "name_symbol", "category", "reviews", "R05_Excellent", "R04_VeryGood", 
                                              "R03_Average", "R02_Poor", "R01_Terrible", "duration", 
                                              "weighted_Rating", "combinedCosts", "Fare")]


combinedTableOutput$timeslots <- gsub(combinedTableOutput$timeslots,pattern = "\n",replacement = " ")
combinedTableOutput$combinedCosts <- gsub(combinedTableOutput$combinedCosts, pattern = "\n", replacement = "|")


write.csv(combinedTableOutput, "Boston_Listing_Details.csv",row.names = F)



library(xlsx)
write.xlsx2(combinedTableOutput,"Boston-Data-Opt.xlsx",row.names = F)

write.csv(combinedTable, "combinedTable_unaltered_data.csv",row.names = F)
saveRDS(combinedTable, file = "combinedTable.rds")
#saveRDS(rr2, file="rr2.rds")
#saveRDS(rr, file="rr.rds")

 

combinedTable$combinedCosts <- gsub(combinedTable$combinedCosts, pattern = "\n", replacement = "|")
combinedTable$timeslots <- gsub(combinedTable$timeslots,pattern = "\n",replacement = " ")



combinedTableOutput$costString <- gsub(combinedTableOutput$costString, pattern = "\n", replacement = "|")
combinedTableOutput$timeslots <- gsub(combinedTableOutput$timeslots,pattern = "\n",replacement = " ")
