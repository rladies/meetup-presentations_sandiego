## LOAD PACKAGES ####
library(tidyverse)
library(lubridate)
library(ggmap)


## READ IN DATA ####
data <- read_csv("data/traffic_counts_datasd.csv")


## SUMMARIZE DATA AND PULL GEOCODES ####
year_limit_aggregate <- data %>%
  # Make column for year
  mutate(count_year = year(count_date)) %>%
  # Get total number of cars by year, street, and limits
  group_by(count_year, street_name, limits) %>%
  summarize(total = sum(total_count)) %>%
  ungroup() %>%
  # Find 10 most popular segments per year
  group_by(count_year) %>%
  arrange(desc(total)) %>%
  filter(row_number() <= 10) %>%
  ungroup() %>%
  # Break limits column into limit start and end
  separate(limits,
           into = c("limit_start", "limit_end"),
           sep = " - ",
           remove = FALSE) %>%
  # Make new columns for location of start and end of segment
  mutate(start_crossing = paste0(street_name,
                                 " and ",
                                 limit_start,
                                 " San Diego, CA"),
         end_crossing = paste0(street_name,
                               " and ",
                               limit_end,
                               " San Diego, CA")) %>%
  # Pull latitude and longitude values of start and end and rename columns
  mutate_geocode(start_crossing, source = "google") %>%
  rename(start_lon = lon,
         start_lat = lat) %>%
  mutate_geocode(end_crossing, source = "google") %>%
  rename(end_lon = lon,
         end_lat = lat)


## PLOT DATA ####
# Pull map of San Diego
san_diego_map <- get_googlemap(center = "San Diego",
                               maptype = "roadmap",
                               zoom = 10,
                               size = c(640, 420),
                               color = "bw")

# Plot popular routes over San Diego map
san_diego_routes_plot <- ggmap(san_diego_map) +
  geom_segment(data = year_limit_aggregate,
               aes(x = start_lon,
                   y = start_lat,
                   xend = end_lon,
                   yend = end_lat,
                   color = factor(count_year),
                   size = total),
               alpha = 0.5)

san_diego_routes_plot
