## LOAD PACKAGES ####
library(tidyverse)
library(forcats)
library(tidycensus)


## READ IN API KEY VALUE AND LOAD ####
source("census_api_key.R")
census_api_key(key)


## GET VARIABLES FOR DATA SET ####
variable_acs_2016 = load_variables(2016, "acs5", cache = TRUE)


## READ IN CENSUS DATA ####
# State populations
state_pops = get_acs(geography = "state",
                     variables = "B01003_001",
                     survey = "acs5",
                     year = 2016)
state_pops = get_acs(geography = "state",
                     variables = c(population = "B01003_001"),
                     survey = "acs5",
                     year = 2016)

# California county populations
ca_county_pops = get_acs(geography = "county",
                         variables = c(population = "B01003_001"),
                         state = "CA",
                         survey = "acs5",
                         year = 2016)

# California and Texas county populations
ca_tx_county_pops = get_acs(geography = "county",
                            variables = c(population = "B01003_001"),
                            state = c("CA", "TX"),
                            survey = "acs5",
                            year = 2016)

# All state county populations
county_pops = get_acs(geography = "county",
                      variables = c(population = "B01003_001"),
                      survey = "acs5",
                      year = 2016)
county_pops = get_acs(geography = "county",
                      variables = c(population = "B01003_001"),
                      survey = "acs5",
                      year = 2016) %>%
  separate(NAME, into = c("county", "state"), sep = ", ")


## MAKE PLOTS ####
# Plot top 10 counties by population in the United States
top_10_counties_plot = county_pops %>%
  arrange(desc(estimate)) %>%
  filter(row_number() <= 10) %>%
  ggplot(aes(x = fct_reorder(county, -estimate),
             y = estimate,
             fill = state)) +
  geom_bar(stat = "identity") +
  theme_classic()

top_10_counties_plot

# Plot bottom 10 counties by population in the United States
bottom_10_counties_plot = county_pops %>%
  arrange(estimate) %>%
  filter(row_number() <= 10) %>%
  ggplot(aes(x = fct_reorder(county, estimate),
             y = estimate,
             fill = state)) +
  geom_bar(stat = "identity") +
  theme_classic()

bottom_10_counties_plot
