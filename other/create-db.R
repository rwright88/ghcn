# -------------------------------------------------------------------------
#
# Script to create database of all data from selected stations.
#
# -------------------------------------------------------------------------

library(tidyverse)
library(ghcn)

dir_files <- "~/data/ghcn/ghcnd_all/"
file_db   <- "~/data/ghcn/ghcndb"

# funs --------------------------------------------------------------------

plot_stations_map <- function(stations) {
  ggplot(stations, aes(longitude, latitude)) +
    geom_point(size = 0.5, alpha = 0.5) +
    scale_x_continuous(breaks = seq(-200, 200, 40)) +
    scale_y_continuous(breaks = seq(-100, 100, 40)) +
    theme_bw()
}

# get station ids ---------------------------------------------------------

stations <- read_stations()

stations_gsn <- filter(stations, !is.na(gsn_flag))
stations_hcn <- filter(stations, !is.na(hcn_crn_flag))
stations_wmo <- filter(stations, !is.na(wmo_id))

wmo_ids <- stations_wmo[["id"]]

plot_stations_map(stations_wmo)

# get file list -----------------------------------------------------------

files <- list.files(dir_files, full.names = TRUE)
files_wmo <- files[str_sub(files, -15, -5) %in% wmo_ids]

# create database ---------------------------------------------------------

system.time(
  create_database(
    path = dir_files,
    file_db = file_db,
    chunk_size = 100
  )
)
