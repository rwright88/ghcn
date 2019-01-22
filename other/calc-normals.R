# calculate climate normals

# https://www.ncdc.noaa.gov/data-access/land-based-station-data/land-based-datasets/climate-normals

library(tidyverse)
library(lubridate)
library(ghcn)

source("other/utils.R")

file_db   <- "~/data/ghcn/ghcndb"
vars_read <- c("id", "date", "prcp", "snow", "snwd", "tmax", "tmin")
year_min  <- 1988
year_max  <- 2017

# funs --------------------------------------------------------------------

#' Calculate an estimated sum of daily values in a month
#'
#' @param x Vector of values for each day in a month
#' @param min_days_p Minimum rate of days in month that are not NA to calculate
#'   sum. If rate is less than this, NA will be returned.
#' @return Vector of length one.
#' @export
month_sum <- function(x, min_days_p = 0.5) {
  days_p <- mean(!is.na(x))

  if (days_p >= min_days_p) {
    sum(x, na.rm = TRUE) / days_p
  } else {
    return(NA_real_)
  }
}

#' Calculate an estimated mean of daily values in a month
#'
#' @param x Vector of values for each day in a month
#' @param min_days_p Minimum rate of days in month that are not NA to calculate
#'   mean. If rate is less than this, NA will be returned.
#' @return Vector of length one.
#' @export
month_mean <- function(x, min_days_p = 0.5) {
  days_p <- mean(!is.na(x))

  if (days_p >= min_days_p) {
    mean(x, na.rm = TRUE)
  } else {
    return(NA_real_)
  }
}

#' Calculate monthly normal
#'
#' @param x Vector of calculated monthly statistics.
#' @param min_years Minimum number of years required to calculate normal. If
#'   number of years is less than this, NA will be returned.
#' @return Vector of length one.
#' @export
month_normal <- function(x, min_years) {
  years <- sum(!is.na(x))

  if (years >= min_years) {
    mean(x, na.rm = TRUE)
  } else {
    return(NA_real_)
  }
}

#' Calculate monthly normals
#'
#' Calculate monthly normals of the five core variables from dly data.
#'
#' @param data Data frame of dly data.
#' @param year_min First year in range to calculate monthly normals.
#' @param year_max Last year in range to calculate monthly normals.
#' @param min_years_p Minimum rate of years in selected range that are not NA to
#'   calculate normal for month. If rate is less than this, NA will be returned.
#' @return Data frame of calculated monthly normals by station.
#' @export
calc_normals <- function(data, year_min, year_max, min_years_p = 0.5) {
  if (year_max < year_min) {
    stop("year_max must be greater than or equal to year_min.", call. = FALSE)
  }

  min_years <- (year_max - year_min + 1) * min_years_p
  vars_all <- c("prcp", "snow", "snwd", "tmax", "tmin")

  months <- data %>%
    dplyr::mutate(
      year  = lubridate::year(.data$date),
      month = lubridate::month(.data$date)
    ) %>%
    dplyr::filter(.data$year %in% year_min:year_max) %>%
    dplyr::group_by(.data$id, .data$year, .data$month) %>%
    dplyr::summarise(
      prcp = month_sum(.data$prcp),
      snow = month_sum(.data$snow),
      snwd = month_mean(.data$snwd),
      tmax = month_mean(.data$tmax),
      tmin = month_mean(.data$tmin)
    ) %>%
    dplyr::ungroup()

  normals <- months %>%
    dplyr::group_by(.data$id, .data$month) %>%
    dplyr::summarise_at(vars_all, month_normal, min_years = min_years) %>%
    dplyr::ungroup()

  normals
}

get_rand_ids <- function(p) {
  if (!(p >= 0 & p <= 1)) {
    stop("p must be between 0 and 1.", call. = FALSE)
  }

  wmo_ids <- read_stations() %>%
    filter(!is.na(wmo_id)) %>%
    .[["id"]]

  n <- round(length(wmo_ids) * p)

  out <- sample(wmo_ids, n)
  out
}

# run ---------------------------------------------------------------------

ids <- get_rand_ids(p = 0.01)

system.time({
  dat <- db_read_dly(file_db, ids = ids, vars = vars_read)
})

normals <- calc_normals(dat, year_min = year_min, year_max = year_max)

microbenchmark::microbenchmark(
  calc_normals(dat, year_min = year_min, year_max = year_max),
  times = 3
)
