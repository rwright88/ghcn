#' Read a ".dly" file
#'
#' @param file Path to file.
#'
#' @return A data frame.
#' @export
read_dly <- function(file) {
  names2 <- vector("character", 31 * 4)
  for (day in 1:31) {
    i <- day * 4 + 1:4 - 4
    names2[i] <- stringr::str_c(c("value", "mflag", "qflag", "sflag"), day)
  }
  col_names <- c("id", "year", "month", "element", names2)

  col_positions <- readr::fwf_widths(
    widths = c(11, 4, 2, 4, rep(c(5, 1, 1, 1), times = 31)),
    col_names = col_names
  )

  col_types <- stringr::str_c("ciic", stringr::str_dup("iccc", 31))

  data <- readr::read_fwf(
    file,
    col_positions = col_positions,
    col_types = col_types,
    na = c("", "-9999"),
    progress = FALSE
  )

  data
}

#' Read ghcnd stations file
#'
#' @param file Path to file.
#'
#' @return A data frame.
#' @export
read_stations <- function(file) {
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

  data <- readr::read_fwf(
    file,
    col_positions = col_positions,
    col_types = "cdddccccc"
  )

  data
}
