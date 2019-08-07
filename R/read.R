#' Read a ".dly" file
#'
#' Read a ".dly" file from the NOAA FTP site, given the station identification
#' code.
#'
#' @param id Station identification code of length one.
#' @return Data frame of dly data.
#' @export
ghcn_read <- function(id) {
  stopifnot(length(id) == 1)
  file <- paste0("ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/all/", id, ".dly")
  tryCatch(
    ghcn_read_file(file),
    error = function(e) NA
  )
}

#' Read a ".dly" file
#'
#' Read a ".dly" file, given the file path.
#'
#' @param file Path to ".dly" data file or connection.
#' @return Data frame of dly data..
#' @export
ghcn_read_file <- function(file) {
  n_days <- 31
  vals_flags <- vector("character", n_days * 4)

  for (day in seq_len(n_days)) {
    i <- day * 4 - 3:0
    vals_flags[i] <- paste0(c("value", "mflag", "qflag", "sflag"), day)
  }

  col_names <- c("id", "year", "month", "element", vals_flags)
  col_positions <- readr::fwf_widths(
    widths = c(11, 4, 2, 4, rep(c(5, 1, 1, 1), times = n_days)),
    col_names = col_names
  )
  col_types <- paste0("ciic", paste0(rep("iccc", n_days), collapse = ""))

  readr::read_fwf(
    file,
    col_positions = col_positions,
    col_types = col_types,
    na = c("", "-9999"),
    progress = FALSE
  )
}

#' Read ghcnd stations file
#'
#' Read ghcnd stations file from the NOAA FTP site.
#'
#' @return Data frame of stations data.
#' @export
ghcn_read_stations <- function() {
  file <- "ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/ghcnd-stations.txt"
  col_names <- c(
    "id",
    "latitude",
    "longitude",
    "elevation",
    "state",
    "name",
    "gsn_flag",
    "hcn_crn_flag",
    "wmo_id"
  )
  col_positions <- readr::fwf_positions(
    start = c( 1, 13, 22, 32, 39, 42, 73, 77, 81),
    end   = c(11, 20, 30, 37, 40, 71, 75, 79, 85),
    col_names = col_names
  )

  readr::read_fwf(
    file,
    col_positions = col_positions,
    col_types = "cdddccccc"
  )
}
