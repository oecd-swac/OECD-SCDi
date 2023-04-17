# Calculate the SCDindicator
# Created by David Russell, University of Florida African Networks Lab
# April 2023

# Please cite as:
# Olivier J. Walther, Steven M. Radil, David G. Russell & Marie Trémolières (2023) 
# Introducing the Spatial Conflict Dynamics Indicator of Political Violence, 
# Terrorism and Political Violence 35 (3): 533-552. DOI: 10.1080/09546553.2021.1957846

###### Read in libraries ######
library(sf)
library(spatialEco)

###### Prepare data ######
### Prepare points data
# Read in xy points data as csv
pointsCSV <- read.csv(file.choose())

# Indicate what the column names for longitude and latitude are (CHANGE ME)
coords <- c("longitude","latitude")

# Indicate the EPSG code for the projection of the data
# (4326) is unprojected WGS84 data (CHANGE ME)
crs = 4326

# Turn this into an sf object
points.unproj <- st_as_sf(pointsCSV, coords = coords, crs = crs)

### Prepare polygons data
# If you have a set of polygons already, read them in
polygons.unproj <- st_read(file.choose())

# Project data (CHANGE ME)
# Choose an appropriate projection that preserves distance
# We use Africa Lambert Conformal Conic for analysis in North and West Africa
crsString <- "+proj=lcc +lat_1=20 +lat_2=-23 
              +lat_0=0 +lon_0=25 +x_0=0 
              +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"
points <- st_transform(points.unproj, crs = crsString)
polygons <- st_transform(polygons.unproj, crs = crsString)

# If you don't have polygons and want to use a 50km x 50km fishnet,
# use this code to generate one 
# (will produce a square study area, so you might want to clip later):

# polygons <- st_make_grid(points, cellsize = c(50000,50000)) %>% st_as_sf()
# You can clip the polygon grid to only those cells that contain points using this:
# polygons <- st_filter(polygons,points)

# Add a unique identifier (ID) column
polygons$ID <- 1:nrow(polygons)

# Remove unnecessary objects from memory to speed computation
rm(pointsCSV,points.unproj,polygons.unproj,coords,crs,crsString)

###### Define function ######
# Calculate the SCDi and related metrics
# for points in a set of polygons,
# given a density cutoff value (the densityCutoff parameter below)

# Returns: a dataframe with rows for each input polygon
# and columns for various SCDi metrics
# Output DF can be merged with the polygons shapes on the "ID" field created above

# (CHANGE ME) If your points data has a column for fatalities
# for that event, un-comment the three lines summing fatalities per polygon (lines 73, 81, and 94)
calcSCDi <- function(points, polygons, densityCutoff) {
  
  # Set up output columns
  Density <- rep(NA,nrow(polygons))
  NN_Index <- rep(NA,nrow(polygons))
  eventCount <- rep(NA,nrow(polygons))
  #fatalities <- rep(NA,nrow(polygons))
  
  # For each polygon in the polygon set, subset points to it
  # and perform nearest neighbor and density calculations on them
  for(i in 1:nrow(polygons)){
    cell <- polygons[i,]
    cellPoints <- points[cell,]
    eventCount[i] <- nrow(cellPoints)
    #fatalities[i] <- sum(cellPoints$fatalities)
    if(nrow(cellPoints) >= 2){
      cellNNI <- nni(cellPoints, win = "extent")
      cellNNInum <- cellNNI$NNI
      if(is.nan(cellNNInum)){
        cellNNInum <- 0
      }
      NN_Index[i] <- cellNNInum
      A <- st_area(cell) / 1000000
      Density[i] <- (nrow(cellPoints) / A)
    }
  }
  outputDF <- data.frame("ID" = polygons$ID, "eventCount" = eventCount, 
                         #"fatalities" = fatalities,
                         "Density" = Density, "NN_Index" = NN_Index)
  
  # Classify observations based on density and NN index
  outputDF$den_class <- NA
  outputDF$NN_class <- NA
  outputDF$den_class[outputDF$Density >= densityCutoff] <- "H"
  outputDF$den_class[outputDF$Density < densityCutoff] <- "L"
  outputDF$NN_class[outputDF$NN_Index < 1 ] <- "C"
  outputDF$NN_class[outputDF$NN_Index >= 1] <- "D"
  
  outputDF$SCDI <- paste0(outputDF$NN_class,outputDF$den_class)
  
  return(outputDF)
}
# To write out data to an ESRI shapefile to your working directory:
st_write(outputDF,"SCDiOutput.shp")

###### Run the above function for a set of time intervals ######
# For this function, you'll need a column in your points dataset
# That has a time interval as a numerical vector
# For instance, a column for the year that the event indicated
# by the point took place.
# e.g., a year column
SCDiOverTime <- function(points, polygons, densityCutoff, timeColumn){
  finalDF <- data.frame("ID" = polygons$ID)
  for(time in min(timeColumn):max(timeColumn)){
    print(time)
    timePoints <- points[timeColumn == time,]
    print(nrow(timePoints))
    timeOutput <- calcSCDi(timePoints,polygons,densityCutoff)
    for(col in 1:length(colnames(timeOutput))){
      colnames(timeOutput)[col] <- paste0(colnames(timeOutput)[col],as.character(time))
    }
    finalDF <- merge(finalDF,timeOutput, by.x = "ID", by.y = paste0("ID",time), all = T)
    print(paste0("Finished processing ",as.character(time)))
  }
  return(finalDF)
}
# To write out data to an ESRI shapefile to your working directory:
st_write(finalDF,"SCDiOutputOverTime.shp")
