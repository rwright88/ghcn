#' Find stations that match pattern
#'
#' @param pattern Character string to match station names.
#' @return Data frame.
#' @importFrom rlang .data
#' @export
find_stations <- function(pattern) {
  stations <- read_stations()
  stations <- dplyr::filter(stations, grepl(
    pattern     = pattern,
    x           = .data$name,
    ignore.case = TRUE,
    perl        = TRUE
  ))
  stations
}
