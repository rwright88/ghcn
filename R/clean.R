#' Clean dly data
#'
#' Transforms dly data so that each row is one day, and each column is a
#' variable. Only includes the five core statistics daily precipitation, snow
#' fall, snow depth, minimum temperature, and maximum temperature. Removes flag
#' variables. Also makes units of measurement consistent across variables.
#'
#' @param data Data frame of dly data read with read_dly.
#' @return Data frame.
#' @importFrom rlang .data
#' @export
clean_dly <- function(data) {
  core <- c("PRCP", "SNOW", "SNWD", "TMAX", "TMIN")

  data <- data %>%
    dplyr::select(c("id", "year", "month", "element"), dplyr::starts_with("value")) %>%
    dplyr::filter(.data$element %in% core) %>%
    tidyr::gather("day", "value", 5:35) %>%
    dplyr::mutate(date = lubridate::make_date(
      year = .data$year,
      month = .data$month,
      day = text_extract(.data$day, "\\d+", perl = TRUE))
    ) %>%
    dplyr::select(c("id", "date", "element", "value"))

  data <- data %>%
    dplyr::filter(!is.na(.data$date)) %>%
    dplyr::mutate(value = clean_vals(.data$value, .data$element)) %>%
    tidyr::spread(.data$element, .data$value) %>%
    dplyr::rename_all(tolower)

  data
}

#' Make unit of measurement consistent across variables
#'
#' Always try to use millimeters for variables that measure length, and degrees
#' Celsius for variables that measure temperature.
#'
#' @param x Vector of values of type integer or double
#' @param element GHCN element type of size x. For example, "PRCP" is the
#'   element type for precipitation.
#' @return Vector of type double.
#' @export
clean_vals <- function(x, element) {
  if (length(x) != length(element)) {
    stop("Unequal vector lengths.")
  }
  x[element == "PRCP"] <- x[element == "PRCP"] / 10
  x[element == "TMAX"] <- x[element == "TMAX"] / 10
  x[element == "TMIN"] <- x[element == "TMIN"] / 10
  x
}
