#' Clean dly data
#'
#' Transforms dly data so that each row is one day, and each column is a
#' variable. Only includes the five core statistics daily precipitation, snow
#' fall, snow depth, minimum temperature, and maximum temperature. Removes flag
#' variables. Also makes units of measurement consistent across variables.
#'
#' @param data Data frame of dly data read with `ghcn_read_dly()`.
#' @return Data frame of dly data.
#' @export
ghcn_clean <- function(data) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }

  vals <- paste0("value", 1:31)
  vars <- c("id", "year", "month", "element", vals)

  if (!all(vars %in% names(data))) {
    stop("`data` does not have the required variables.", call. = FALSE)
  }

  core <- c("PRCP", "SNOW", "SNWD", "TMAX", "TMIN")

  data <- data[vars]
  data <- data[data$element %in% core, ]
  data <- tidyr::gather(data, "day", "value", vals)
  data$date <- lubridate::make_date(data$year, data$month, text_extract(data$day, "\\d+", perl = TRUE))
  data <- data[c("id", "date", "element", "value")]
  data <- data[!is.na(data$date), ]
  data$value <- ghcn_clean_vals(data$value, element = data$element)
  data <- tidyr::spread(data, "element", "value")
  data <- setNames(data, tolower(names(data)))
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
ghcn_clean_vals <- function(x, element) {
  if (length(x) != length(element)) {
    stop("`x` and `element` must have equal lengths.", call. = FALSE)
  }
  x[element == "PRCP"] <- x[element == "PRCP"] / 10
  x[element == "TMAX"] <- x[element == "TMAX"] / 10
  x[element == "TMIN"] <- x[element == "TMIN"] / 10
  x
}
