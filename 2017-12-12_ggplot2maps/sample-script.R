# Example script for making maps from scratch with ggplot2
# This file is a companion to the document Overview.md
# Amy F. Szczepanski
# August 2017

library(gpclib) 
library(rgdal)
library(ggplot2)

# Edit this line to point to the directory where you have the data
setwd("/Full/path/goes/here")

# Reading in shapefiles and fortifying them into dataframes
# This data needs to be downloaded from the census and the city
# See below to read in the data from the CSV files I've provided

# Census TIGER/Line shapefiles can be found at:
# https://www.census.gov/geo/maps-data/data/tiger-line.html

# City of San Diego park shapefile can be found at 
# https://data.sandiego.gov/datasets/park-locations/

# If you get an error when fortifying the parks, water, or roads, try eliminating the region= argument, and try again.

# Reading and fortifying the shapefile for parks.
sandiego.parks <- readOGR(dsn="CITY.PARKS_datasd", layer="CITY_PARKS")
sandiego.parks.ll <- spTransform(sandiego.parks, CRS("+proj=longlat +datum=WGS84"))
sandiego.parks.fort <- fortify(sandiego.parks.ll, region="OBJECTID")

# Reading and fortifying the shapefile for water.
sandiego.water <- readOGR(dsn="tl_2016_06073_areawater", layer="tl_2016_06073_areawater")
sandiego.water.fort <- fortify(sandiego.water)

# Reading and fortifying the shapefile for roads
ca.roads <- readOGR(dsn = "tl_2016_06_prisecroads", layer="tl_2016_06_prisecroads")
ca.roads.fort <- fortify(ca.roads, region="FULLNAME")

# Reading and fortifying the shapefile for census tracts
census.tracts <- readOGR(dsn="tl_2016_06_tract", layer="tl_2016_06_tract")
census.tracts.fort <- fortify(census.tracts, region="GEOID")

# If you can't read or fortify the shapefiles, I've saved the fortified data
# (Or if you can't download them from the census and the city)
# You can use this to make the sample map
# Un-comment out the following lines.

#census.tracts.fort <- read.csv(file="limited_include_tracts.csv", colClasses=c("numeric", "numeric", "integer", "logical", "character", "character", "character"))
#ca.roads.fort <- read.csv(file="limited_ca_roads.csv", colClasses=c("numeric", "numeric", "integer", "character", "character", "character"))
#sandiego.parks.fort <- read.csv(file="sandiego_parks_fort.csv", colClasses=c("numeric", "numeric", "integer", "logical", "character", "character", "character"))
#sandiego.water.fort <- read.csv(file="sandiego_water_fort.csv", colClasses=c("numeric", "numeric", "integer", "logical", "character", "character", "character"))


# Reading in the data for median home price per census tract
# Median price is in variables HD01_VD01
median.price.all.rows <- readLines("ACS_15_5YR_B25077.csv")
median.price.one.header <- median.price.all.rows[-2]
median.price.frame <- read.csv(textConnection(median.price.one.header), header=TRUE, colClasses = c("character", "character", "character", "numeric", "numeric"))
median.price.frame <- median.price.frame[!is.na(median.price.frame$HD01_VD01),]

# Matching the median prices to the geographic boundaries
median.price.by.tract <- merge(x=census.tracts.fort, y=median.price.frame, by.x="id", by.y="GEO.id2")
median.price.by.tract <- median.price.by.tract[order(median.price.by.tract[,4]),]

# Reading the data for the flight paths
flights <- read.csv(file="flights.csv", colClasses=c("POSIXct", "numeric", "numeric", "numeric", "factor"))

# Making the plot
ggplot(data=sandiego.water.fort, aes(x=long, y=lat)) + geom_map(data=median.price.by.tract, map=median.price.by.tract, aes(map_id=id, fill=HD01_VD01)) + geom_map(map=sandiego.water.fort, aes(map_id=id), color="#a4c1e8", fill="#a4c1e8") + annotate("rect", xmin=-117.4, xmax=-117.29, ymin=-Inf, ymax=Inf, fill="#a4c1e8") + annotate("rect", xmin=-117.3, xmax=-117.2, ymin=-Inf, ymax=32.65, fill="#a4c1e8") + geom_map(data=sandiego.parks.fort, map= sandiego.parks.fort, aes(map_id=id), color="#93c1a2", fill="#93c1a2") + geom_path(data=ca.roads.fort, aes(x=long, y=lat, group=group)) + geom_point(data=flights, aes(x=lon, y=lat, shape=flight), size=3) + coord_map(xlim=c(-117.4, -117.0), ylim=c(32.6, 32.8)) + scale_fill_continuous(low="#8b35a5", high="#f98704", name="Median home price") + theme_void()