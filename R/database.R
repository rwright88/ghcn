#' Create database of daily data from ".dly" data files
#'
#' Create database of daily data from a vector of ".dly" data files. The data
#' will only include the five core statistics daily precipitation, snow
#' fall, snow depth, minimum temperature, and maximum temperature. If the
#' database already exists, it will be deleted first.
#'
#' @param files File paths of dly data files
#' @param file_db File path of database
#' @param table_name Database table name
#' @param batch_size Number of data files to write to database table per batch
#' @export
ghcn_db_write <- function(files, file_db, table_name, batch_size = 100) {
  n_files <- length(files)
  if (n_files < 1) {
    stop("Length of `files` must be at least 1.", call. = FALSE)
  }

  if (!(batch_size %in% 1:n_files)) {
    stop("`batch_size` must be between 1 and the number of `files`.")
  }

  files_exist <- all(vapply(files, FUN.VALUE = logical(1), FUN = file.exists))
  if (files_exist != TRUE) {
    stop("One or more of the files do not exist.", call. = FALSE)
  }

  if (file.exists(file_db)) {
    file.remove(file_db)
  }

  con <- DBI::dbConnect(RSQLite::SQLite(), file_db)
  n_batches <- ceiling(n_files / batch_size)
  vars_all <- c("id", "date", "prcp", "snow", "snwd", "tmax", "tmin")

  for (i in seq_len(n_batches)) {
    first <- (i - 1) * batch_size + 1
    last <- min(first + batch_size - 1, n_files)
    files_batch <- files[first:last]

    data <- lapply(files_batch, ghcn_read_file)
    data <- dplyr::bind_rows(data)
    data <- ghcn_clean(data)
    vars <- names(data)
    vars_miss <- vars_all[!(vars_all %in% vars)]

    if (length(vars_miss) > 0) {
      data[vars_miss] <- NA
    }

    DBI::dbWriteTable(
      conn = con,
      name = table_name,
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
ghcn_db_read <- function(file_db, ids, vars) {
  if (!is.character(ids)) {
    stop("`ids` must be a character vector", call. = FALSE)
  }
  if (!is.character(vars)) {
    stop("`vars` must be a character vector", call. = FALSE)
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
