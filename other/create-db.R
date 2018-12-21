# -------------------------------------------------------------------------
#
# Script to create database of all data from selected stations.
#
# -------------------------------------------------------------------------

library(tidyverse)
library(RSQLite)
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

query_rand <- function(file_db, n_rows) {
  con <- dbConnect(SQLite(), file_db)
  query <- paste0("SELECT * FROM dly_core ORDER BY RANDOM() LIMIT ", n_rows, ";")
  res <- dbSendQuery(con, query)
  dat <- dbFetch(res)
  dbClearResult(res)
  dbDisconnect(con)
  dat <- as_tibble(dat)
  dat
}

# run ---------------------------------------------------------------------

plot_stations_wmo()

files <- get_files_wmo(dir_files)

# system.time(
#   ghcn::create_database(
#     files = files,
#     file_db = file_db,
#     chunk_size = 100
#   )
# )

query_rand(file_db)
