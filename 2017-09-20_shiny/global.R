#################
# The global R script is where I read in packages and data used in the app
#################

options(shiny.sanitize.errors = FALSE)

#################
# Load packages
library(shiny)
library(data.table)
library(ggmap)
library(leaflet)
library(ggplot2)
library(rsconnect)
library(shinythemes)

# Source the R ladies theme for the ggplot
source('R ladies theme.R')
#################

#################
## Read in datasets for Rladies Global & Rladies San Diego from
## Put all datasets in the same directory as your ui.R and server.R files
## "fread" is the fast-read function in the data.table package
## I got these data from the Rladies github: https://github.com/rladies-san-diego/2017-07-13_rmarkdown/blob/master/rladies_sandiego.csv

# List of R ladies chapters with geocoded cities
dat_global <- fread("Rladiesglobal_withLatLong.csv")

# Survey data from first R-ladies meet up reshaped for use with ggplot
dat_SD_melt <- fread("RladiesSD_melt.csv")
#################

