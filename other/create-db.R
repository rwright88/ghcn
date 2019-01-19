# -------------------------------------------------------------------------
#
# Script to create database of all historical data from selected stations.
#
# -------------------------------------------------------------------------

library(tidyverse)
library(ghcn)

dir_files <- "~/data/ghcn/ghcnd_all/"
file_db   <- "~/data/ghcn/ghcndb"

# funs --------------------------------------------------------------------

plot_stations_wmo <- function() {
  stations <- read_stations() %>%
    filter(!is.na(wmo_id))

  stations %>%
    ggplot(aes(longitude, latitude)) +
    geom_point(size = 0.5, alpha = 0.5) +
    scale_x_continuous(breaks = seq(-200, 200, 40)) +
    scale_y_continuous(breaks = seq(-100, 100, 40)) +
    theme_bw()
}

get_files_wmo <- function(dir) {
  wmo_ids <- read_stations() %>%
    filter(!is.na(wmo_id)) %>%
    .[["id"]]

  files <- list.files(dir, full.names = TRUE)
  files <- files[str_sub(files, -15, -5) %in% wmo_ids]
  files
}

# run ---------------------------------------------------------------------

plot_stations_wmo()

files_wmo <- get_files_wmo(dir = dir_files)

system.time(
  db_write_dly(
    files = files_wmo,
    file_db = file_db,
    chunk_size = 100
  )
)
