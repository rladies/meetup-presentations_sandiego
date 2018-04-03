## LOAD PACKAGES ####
library(tidyverse)
library(forcats)
library(tidycensus)
library(albersusa)


## READ IN API KEY VALUE AND LOAD ####
source("census_api_key.R")
census_api_key(key)


## GET VARIABLES FOR DATA SET ####
variable_acs_2016 = load_variables(2016, "acs5", cache = TRUE)

language_home_variables = paste0("B16001_", stringr::str_pad(seq(3, 99, by = 3), 3, pad = "0"), "E")

languages_home_info = variable_acs_2016 %>%
  filter(name %in% language_home_variables) %>%
  mutate(name = stringr::str_replace(name, "E", "")) %>%
  mutate(language = stringr::str_replace(label, "Estimate!!Total!!", "")) %>%
  select(name, language)

language_home_codes = setNames(as.character(languages_home_info$name), languages_home_info$language)


## READ IN CENSUS DATA ####
# State Spanish usage
spanish_home_usage = get_acs(geography = "state",
                             variables = c(spanish = "B16001_003"),
                             survey = "acs5",
                             year = 2016)

# State non-English usage
languages_home_usage = get_acs(geography = "state",
                               variables = languages_home_info$name,
                               survey = "acs5",
                               year = 2016)
languages_home_usage = get_acs(geography = "state",
                               variables = language_home_codes,
                               survey = "acs5",
                               year = 2016)
languages_home_usage = get_acs(geography = "state",
                               variables = language_home_codes,
                               survey = "acs5",
                               summary_var = "B01003_001",
                               year = 2016) %>%
  mutate(pct_estimate = estimate / summary_est) %>%
  rename(state = NAME)


## MAKE PLOTS ####
# Top states by percentage of French speakers
top_french_states_plot = languages_home_usage %>%
  filter(variable == "French (incl. Cajun)") %>%
  arrange(desc(pct_estimate)) %>%
  filter(row_number() <= 10) %>%
  ggplot(aes(x = fct_reorder(state, -pct_estimate),
             y = pct_estimate)) +
  geom_bar(stat = "identity") +
  scale_y_continuous(labels = scales::percent) +
  theme_classic()

top_french_states_plot

# Get United States map data
us_map = usa_composite()
us_states = fortify(us_map, region = "name") %>%
  rename(state = id)

# Map of most common languages (besides English) for each state
top_languages_by_state = languages_home_usage %>%
  group_by(state) %>%
  arrange(desc(pct_estimate)) %>%
  filter(row_number() == 1) %>%
  ungroup() %>%
  inner_join(us_states) %>%
  ggplot(aes(x = long,
             y = lat,
             group = group,
             fill = variable,
             alpha = pct_estimate)) +
  geom_polygon(color = "white") +
  coord_map(projection = "polyconic") +
  scale_alpha_continuous(labels = scales::percent) +
  theme_void() +
  theme(legend.position = "top")

top_languages_by_state

# Map of most common languages (besides English, Spanish) for each state
top_languages_by_state = languages_home_usage %>%
  filter(variable != "Spanish") %>%
  group_by(state) %>%
  arrange(desc(pct_estimate)) %>%
  filter(row_number() == 1) %>%
  ungroup() %>%
  inner_join(us_states) %>%
  ggplot(aes(x = long,
             y = lat,
             group = group,
             fill = variable,
             alpha = pct_estimate)) +
  geom_polygon(color = "white") +
  coord_map(projection = "polyconic") +
  scale_alpha_continuous(labels = scales::percent) +
  theme_void() +
  theme(legend.position = "top")

top_languages_by_state
