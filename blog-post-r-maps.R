# This script uses Kevin Johnson's blog post as a guide http://www.kevjohnson.org/making-maps-in-r/
# loading required packages
x <- c("ggplot2", "rgdal", "scales", "ggmap", "dplyr", "maptools")
lapply(x, require, character.only = TRUE)

# set working directory to project folder
# replace the path below with 
setwd("C:/Users/dapolley/Desktop/geo_test")

# load Indiana county shapefile downloaded from US Census TIGER files
# uses readOGR() fucntion from rgdal package
county <- readOGR(dsn = "tl_2010_18_county10", layer = "tl_2010_18_county10")

# check to see variable that contains geographic info for county
# COUNTYFP10 - county FIPS code
# COUNTYNS10 - county ANSI code
# GEOID10 - concatenation of county FIPS codes and state FIPS codes
# names() function shows all variables in a dataset
names(county)

# fortify from ggplot2; transforms data from shapefiles into dataframe that ggplot can understand
county <- fortify(county, region="COUNTYFP10")

# loading data for Indiana counties from 2014 ACS
data <- read.csv("data/ACS_14_5YR_S1901.csv", stringsAsFactors = FALSE)

# subset data to geo.id2 and median household income
data <- data[,c("GEO.id2", "HC01_EST_VC13")]

# rename columns id and median_income
colnames(data) <- c("id", "median_income")

# convert id from integer to character, this will make combining datasets based on id easier
data$id <- as.character(data$id)

# transform county$id so that it matches data$id; county$id is missing the preceding "18"
county$id <- paste("18", county$id, sep = "")

# join data and county based on id using left_join from dplyr
plot_data <- left_join(county,data)

# create plot using ggplot2 geom_polygon
ggplot() +
  geom_polygon(data = plot_data, aes(x = long, y = lat, group = group, fill = median_income), color = "black", size = 0.25)

# the coord_map() function will maintain the proper shape of the map no matter the dimensions of the image
ggplot() +
  geom_polygon(data = plot_data, aes(x = long, y = lat, group = group, fill = median_income), color = "black", size = 0.25) +
  coord_map()

# change color scheme using ColorBrewer
ggplot() +
  geom_polygon(data = plot_data, aes(x = long, y = lat, group = group, fill = median_income), color = "black", size = 0.05) +
  coord_map() +
  scale_fill_distiller(palette = "Greens") +
  guides(fill = guide_legend(reverse = TRUE)) +
  theme_nothing(legend = TRUE) +
  labs(title = "Median Income for Indiana Counties", fill = "Median Income")
  
  


