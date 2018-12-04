# -------------------------------------------------------------------------
#
# Script to benchmark stuff and other things.
#
# -------------------------------------------------------------------------

library(tidyverse)
library(RSQLite)
library(ghcn)

dir_files <- "~/data/ghcn/ghcnd_gsn"
file_db   <- "~/data/ghcn/ghcndb"

# funs --------------------------------------------------------------------

f1 <- function(files) {
  data <- map_dfr(files, ~clean_dly(read_dly_file(.)))
  data
}

f2 <- function(files) {
  data <- map_dfr(files, read_dly_file)
  data <- clean_dly(data)
  data
}

bench_createdb <- function(dir_files, file_db) {
  n_files <- length(list.files(dir_files))
  res <- system.time(
    create_database(dir_files, file_db)
  )
  res / n_files
}

# https://stackoverflow.com/questions/4114940/select-random-rows-in-sqlite
query_rand <- function(file_db, n_rows = 1e3) {
  con <- dbConnect(SQLite(), file_db)
  query <- paste0("SELECT * FROM dly_core ORDER BY RANDOM() LIMIT ", n_rows, ";")
  # query <- paste0("SELECT * FROM dly_core WHERE id IN (SELECT id FROM dly_core ORDER BY RANDOM() LIMIT ", n_rows, ");")
  res <- dbSendQuery(con, query)
  dat <- dbFetch(res)
  dbClearResult(res)
  dbDisconnect(con)
  dat <- as_tibble(dat)
  dat
}

# run ---------------------------------------------------------------------

# n <- 100
# files <- list.files(dir_files, full.names = TRUE)
# files <- files[sample(n)]
#
# system.time(dly1 <- f1(files)) / n
# system.time(dly2 <- f2(files)) / n
#
# all.equal(
#   arrange(dly1, date),
#   arrange(dly2, date)
# )
#
# summary(dly1)
#
# lobstr::obj_size(dly1) / n

# res <- bench_createdb(dir_files, file_db)
# res

system.time(
  dat <- query_rand(file_db)
)
