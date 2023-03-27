#Define functions to calculate the SCDindicator
#David Russell, January 2021
# Updated February 2022 to incorporate reading data directly from ACLED API
# Updated September 2022 to incorporate new ACLED data (through June 2022)
# Updated February 2023 to incorporate new ACLED data (through December 2022)
# and to simplify script to prepare for sharing

######Set Up Functions######
library(spatialEco)
library(rgdal)
library(maptools)
library(sp)
library(rgeos)
library(acled.api)
library(tidyverse)
library(sf)

#Function to find the ANN and density of points per cell in a fishnet
ANNdensCalc <- function(points,fishnet) {
  #Set up output columns
  Density <- rep(NA,nrow(fishnet))
  NN_Index <- rep(NA,nrow(fishnet))
  eventCount <- rep(NA,nrow(fishnet))
  fatalities <- rep(NA,nrow(fishnet))
  for(i in seq(1,nrow(fishnet),1)){
    cell <- fishnet[i,]
    cellPoints <- points[cell,]
    eventCount[i] <- nrow(cellPoints)
    fatalities[i] <- sum(cellPoints$fatalities)
    if(nrow(cellPoints) >= 2){
      cellPoints <- SpatialPointsDataFrame(coords = cellPoints@coords, 
                                           data = cellPoints@data, bbox = bbox(cell),
                                           proj4string = CRS("+proj=lcc +lat_1=20 +lat_2=-23 
                                           +lat_0=0 +lon_0=25 +x_0=0 
                              +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"))
      cellPoints <- st_as_sf(cellPoints)
      cellNNI <- nni(cellPoints, win = "extent")
      NN_Index[i] <- cellNNI$NNI
      A <- cell@polygons[[1]]@area / 1000000 #Get the area of this cell (converting from m2 to km2)
      Density[i] <- (nrow(cellPoints) / A)
    }
  }
  outputDF <- data.frame("ID" = fishnet$ID, "eventCount" = eventCount, "fatalities" = fatalities,
                         "Density" = Density, "NN_Index" = NN_Index)

  return(outputDF)
}

#Function to classify a fishnet with ANN and density values according to cutoffs
#Pay attention to density units!
SCDIclass <- function(resultFishnet,densCutoff) {
  #Classify observations based on density and NN+index
  resultFishnet$den_class <- NA
  resultFishnet$NN_class <- NA
  resultFishnet$den_class[resultFishnet$Density >= densCutoff] <- "H"
  resultFishnet$den_class[resultFishnet$Density < densCutoff] <- "L"
  resultFishnet$NN_class[resultFishnet$NN_Index < 1 ] <- "C"
  resultFishnet$NN_class[resultFishnet$NN_Index >= 1] <- "D"
  
  resultFishnet$SCDI <- paste0(resultFishnet$NN_class,resultFishnet$den_class)
  
  return(resultFishnet)
}



### Run to here to set up libraries and functions



######Run everything with updated ACLED data#####
# Read in fishnet and add a cell ID field
#setwd("C:/Users/david/Dropbox/SWAC2023-24/data/ACLED/SCDIupdateEnd2022")
setwd("C:/Users/drussell/Dropbox (UFL)/SWAC2023-24/data/ACLED/SCDIupdateEnd2022")

countries <- c("Morocco","Algeria","Tunisia","Libya",
               "Western Sahara","Mauritania","Mali","Niger","Chad",
               "Senegal","Gambia","Guinea-Bissau","Guinea","Sierra Leone",
               "Liberia","Ivory Coast","Burkina Faso","Ghana","Togo","Benin",
               "Nigeria","Cameroon")

ACLED<- acled.api(email.address = "owalther@ufl.edu",
                  access.key = "mRrZXTIDUQt0TgZ8pCQM",
                  country = countries,
                  region = NULL,
                  start.date = "1997-01-01",
                  end.date = "2022-12-31",
                  add.variables = NULL,
                  all.variables = TRUE,
                  dyadic = FALSE,
                  other.query = NULL)

ACLED <- as.data.frame(ACLED) ## makes sure the data is formatted correctly
ACLED <- ACLED %>% mutate_all(na_if,"") ## Change blanks to "NA"

ACLED <- ACLED[ACLED$event_type %in% c("Battles","Explosions/Remote violence",
                                       "Violence against civilians"),]

write.csv(ACLED,"ACLEDthruDec2022.csv",row.names = F)

fishnet <- readOGR("C:/Users/drussell/Dropbox (UFL)/SWAC2023-24/gis/fishnet/fishnet_50k_proj.shp")
fishnet$ID <- 1:nrow(fishnet)

#Read in ACLED data and turn into an SPDF and project into Africa Lambert Conformal Conic
#points <- read.csv("ACLEDto20210630.csv") 
points <- ACLED
points$latitude <- as.numeric(points$latitude)
points$longitude <- as.numeric(points$longitude)

lonLat <- points[,c(which(colnames(points) == "longitude"),
                        which(colnames(points) == "latitude"))]
points.spdf <-  SpatialPointsDataFrame(coords = lonLat, 
                                       data = points, 
                                       proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 
                                                         +towgs84=0,0,0"))
points.prj <- spTransform(points.spdf, 
                          CRS("+proj=lcc +lat_1=20 +lat_2=-23 +lat_0=0 +lon_0=25 +x_0=0 
                              +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"))

#Run the functions for every year
densCutoff <- 0.0017
finalDF <- data.frame("ID" = fishnet$ID)
for(year in seq(1997,2022,1)){
  yearPoints <- points.prj[points.prj$year == year,]
  yearOutput <- ANNdensCalc(yearPoints,fishnet)
  yearOutput <- SCDIclass(yearOutput,densCutoff)
  for(col in seq(1,length(colnames(yearOutput)),1)){
    colnames(yearOutput)[col] <- paste0(colnames(yearOutput)[col],as.character(year))
  }
  finalDF <- merge(finalDF,yearOutput, by.x = "ID", by.y = paste0("ID",year), all = T)
  print(paste0("Finished processing ",as.character(year)))
}
#write.csv(finalDF,"SCDiThruJun2021.csv",row.names = F)
fishnetSCDI <- merge(fishnet,finalDF,by.x = "ID",by.y = "ID", all = T)
#writeOGR(fishnetSCDI,layer = "fishnetSCDI", "SCDi.shp", driver = "ESRI Shapefile")


# Add in column for which countries the cell borders
#setwd("C:/Users/david/Dropbox/SWAC2021-22/Data/ACLED/")
#fishnetSCDI <- readOGR("SCDi.shp")
swacCountries <- readOGR("C:/Users/drussell/Dropbox (UFL)/SWAC2023-24/gis/africaCountryBorders/World_Countries_ISO3Africa.shp")
swacCountries <- swacCountries[swacCountries$NAME_EN %in% c(countries,"Cote d'Ivoire"),]
#swacCountries <- swacCountries[swacCountries$CNTR_CODE_ != "UA",]

swacCountries <- spTransform(swacCountries, 
                          CRS("+proj=lcc +lat_1=20 +lat_2=-23 +lat_0=0 +lon_0=25 +x_0=0 
                              +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"))
fishnetSCDI$countries <- ""

for(ic in seq(1,nrow(swacCountries),1)){
  country <- swacCountries[ic,]
  countryName <- country$NAME_EN
  print(countryName)
  for(i in seq(1,nrow(fishnetSCDI),1)){
    cell <- fishnetSCDI[i,]
    if(gIntersects(cell,country)){
      fishnetSCDI$countries[i] <- paste0(fishnetSCDI$countries[i],countryName," ")
    }
  }
  print(paste0("Finished processing ",countryName))
}
fishnetSCDI$countries <- trimws(fishnetSCDI$countries)
writeOGR(fishnetSCDI,layer = "fishnetSCDI", "SCDiDec2022.shp", driver = "ESRI Shapefile")
write.csv(fishnetSCDI@data,"SCDiDec2022.shp.csv",row.names = F)

