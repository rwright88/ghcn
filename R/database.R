#' Create database of daily data from ".dly" data files
#'
#' Create database of daily data from a vector of ".dly" data files. The data
#' will only include the five core statistics daily precipitation, snow
#' fall, snow depth, minimum temperature, and maximum temperature.
#'
#' @param files Character vector of ".dly" data file paths.
#' @param file_db File path of new database to write to.
#' @param chunk_size Number of files of data to append at a time to database
#'   table.
#' @export
db_write_dly <- function(files, file_db, chunk_size = 100) {
  n_files <- length(files)
  if (n_files == 0) {
    stop("Number of files must be greater than 0.")
  }

  if (file.exists(file_db)) {
    file.remove(file_db)
  }
  con <- DBI::dbConnect(RSQLite::SQLite(), file_db)

  n_chunks <- ceiling(n_files / chunk_size)
  vars_all <- c("id", "date", "prcp", "snow", "snwd", "tmax", "tmin")

  for (chunk in seq_len(n_chunks)) {
    i_first <- (chunk - 1) * chunk_size + 1
    i_last <- min(i_first + chunk_size - 1, n_files)
    files_chunk <- files[i_first:i_last]

    data <- purrr::map_dfr(files_chunk, read_dly_file)
    data <- clean_dly(data)
    vars <- names(data)
    vars_miss <- vars_all[!(vars_all %in% vars)]

    if (length(vars_miss) > 0) {
      data[vars_miss] <- NA
    }

    DBI::dbWriteTable(
      conn = con,
      name = "dly_core",
      value = data,
      overwrite = FALSE,
      append = TRUE
    )
  }

  DBI::dbExecute(con, statement = "CREATE INDEX idx1 ON dly_core(id)")
  DBI::dbDisconnect(con)
}

#' Read database dly table.
#'
#' @param file_db Path of database file to read.
#' @param ids Station IDs in data to query (where).
#' @param vars Variables in data to query (select).
#' @return Data frame.
#' @export
db_read_dly <- function(file_db, ids, vars) {
  if (!is.character(ids)) {
    stop("ids must be a character vector", call. = FALSE)
  }
  if (!is.character(vars)) {
    stop("vars must be a character vector", call. = FALSE)
  }

  id <- NULL

  con <- DBI::dbConnect(RSQLite::SQLite(), file_db)

  data <- con %>%
    dplyr::tbl("dly_core") %>%
    dplyr::filter(id %in% ids) %>%
    dplyr::select(vars) %>%
    dplyr::collect()

  if ("date" %in% names(data)) {
    data[["date"]] <- lubridate::as_date(data[["date"]])
  }

  DBI::dbDisconnect(con)
  data
}
