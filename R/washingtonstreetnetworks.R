
# SETUP -------------------------------------------------------------------

library(tidyverse)
library(sf)
library(mapview)
library(janitor)
library(here)
library(tigris)
library(rgdal)

g <- dplyr::glimpse

options(tigris_class = 'sf')

# LOAD GLOBAL URBAN STREET NETWORK DATA -----------------------------------

# Data source: https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/E5TPDQ
# Instructions download the United States zip file and save it
# in the /data directory

zipfile <- file.path(here::here("data/united_states-USA_gpkg.zip"))

exdir <- file.path(here::here("data/gusn-usa/"))

if(!dir.exists(exdir)){
  dir.create(exdir)
}

if(!file.exists(file.path(exdir,"seattle-140.gpkg"))){
  unzip(zipfile, exdir = exdir)
}

ogrListLayers("data/gusn-usa/seattle-140.gpkg")
#> [1] "nodes" "edges"


# MERGE ALL URBAN AREAS IN DIRECTORY --------------------------------------

usa_nodes <- list.files("data/gusn-usa", full.names = TRUE) %>%
  map_dfr(read_sf, layer = "nodes")



# EXTRACT SEATTLE URBAN AREA ----------------------------------------------

seattle_area_nodes <- read_sf("data/gusn-usa/seattle-140.gpkg", layer = "nodes")

# seattle_area_nodes %>%
#   slice_sample(prop  = .01) %>%
#   mapview()



# DOWNLOAD SEATTLE FROM TIGRIS --------------------------------------------

places <- places(53)

seattle_boundary <- places %>%
  clean_names() %>%
  filter(name == "Seattle") %>%
  st_transform(4326)



# FILTER SEATTLE FROM SEATTLE URBAN AREA ----------------------------------

seattle_nodes <- seattle_area_nodes[seattle_boundary,] %>%
  rename(lon = x, lat = y)

# seattle_nodes %>%
#   slice_sample(prop  = .01) %>%
#   mapview()


# PREPARE DATA FOR URBAN INSTITUTE EQUITY TOOL ----------------------------

# https://apps.urban.org/features/equity-data-tool/

minn_bike_stations <- read_csv("data/minneapolis_bikes.csv")

# minn_bike_stations %>% g

# WRITE PROCESSED DATA TO FILE --------------------------------------------

seattle_nodes %>%
  st_drop_geometry() %>%
  write_csv("outputs/seattle_nodes.csv")

usa_nodes %>%
  st_drop_geometry() %>%
  transmute(lon = x, lat = y) %>%
  write_csv("outputs/usa_nodes.csv")
