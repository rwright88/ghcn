#' Find stations that match pattern
#'
#' @param pattern Character string to match station names.
#'
#' @return Data frame.
#' @export
find_stations <- function(pattern) {
  file_stations <- "https://www1.ncdc.noaa.gov/pub/data/ghcn/daily/ghcnd-stations.txt"
  stations <- read_stations(file_stations)
  stations <- dplyr::filter(stations, grepl(
    pattern     = pattern,
    x           = .data$name,
    ignore.case = TRUE,
    perl        = TRUE
  ))
  stations
}
