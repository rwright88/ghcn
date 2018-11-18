#' Clean dly data
#'
#' Transforms dly data so that each row is one day, and each column is a
#' variable. Removes flag variables. Also attempts to make units of measurement
#' consistent across variables.
#'
#' @param data Data frame of dly data.
#'
#' @return Data frame.
#' @export
clean_dly <- function(data) {
  # for now, only keeping five core elements
  core <- c("PRCP", "SNOW", "SNWD", "TMAX", "TMIN")

  data <- data %>%
    dplyr::select(id, year, month, element, dplyr::starts_with("value")) %>%
    dplyr::filter(element %in% core) %>%
    tidyr::gather("day", "value", 5:35) %>%
    dplyr::mutate(date = lubridate::make_date(year, month, stringr::str_extract(day, "\\d+"))) %>%
    dplyr::select(id, date, element, value)

  data <- data %>%
    dplyr::filter(!is.na(date)) %>%
    dplyr::mutate(value = make_consistent(value, element)) %>%
    tidyr::spread(element, value) %>%
    dplyr::rename_all(stringr::str_to_lower)

  data
}

#' Make unit of measurement consistent across variables
#'
#' Always try to use millimeters for variables that measure length, and degrees
#' Celsius for variables that measure temperature.
#'
#' @param x Vector of values of type integer or double
#' @param element GHCN element type of size x. For example, "PRCP" is the
#'   precipitation.
#'
#' @return Vector of type double.
#' @export
make_consistent <- function(x, element) {
  if (length(x) != length(element)) {
    stop("Unequal vector lengths.")
  }
  x[element == "PRCP"] <- x[element == "PRCP"] / 10
  x[element == "TMAX"] <- x[element == "TMAX"] / 10
  x[element == "TMIN"] <- x[element == "TMIN"] / 10
  x
}
