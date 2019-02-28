# daily climate normals
# https://www.ncdc.noaa.gov/cdo-web/datatools/normals

library(tidyverse)
library(lubridate)
library(ghcn)

ids <- c(
  "Allentown" = "USW00014737",
  "Richmond"  = "USW00013740"
)

year_min  <- 1981
year_max  <- 2010

# funs --------------------------------------------------------------------

get_data <- function(ids) {
  data <- map_dfr(ids, read_dly)
  data <- clean_dly(data)
  data$id <- names(ids)[match(data$id, ids)]
  data <- mutate_at(data, c("tmin", "tmax"), ~ .x * 1.8 + 32)
  data
}

normal_day <- function(x, min_years) {
  years <- sum(!is.na(x))

  if (years >= min_years) {
    mean(x, na.rm = TRUE)
  } else {
    return(NA_real_)
  }
}

model_day <- function(x, day) {
  predict(loess(x ~ day, span = 0.3))
}

calc_normals <- function(data, year_min, year_max, min_years) {
  day_nums <- data %>%
    mutate(year = year(date)) %>%
    filter(year %in% year_min:year_max, !(month(date) == 2 & day(date) == 29)) %>%
    arrange(id, date) %>%
    group_by(id, year) %>%
    mutate(day_num = row_number(date)) %>%
    ungroup()

  normals <- day_nums %>%
    group_by(id, day_num) %>%
    summarise_at(c("tmin", "tmax"), ~ normal_day(.x, min_years = min_years)) %>%
    ungroup()

  modeled <- normals %>%
    group_by(id) %>%
    mutate(
      tmin_mod = model_day(tmin, day_num),
      tmax_mod = model_day(tmax, day_num)
    ) %>%
    ungroup()

  modeled
}

plot_daily <- function(data) {
  breaks <- c(1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335)
  labels <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

  data %>%
    gather("type", "value", -id, -day_num) %>%
    ggplot(aes(day_num, value, group = type)) +
    geom_line(size = 0.5, color = "#1f77b4") +
    scale_x_continuous(breaks = breaks, labels = labels, minor_breaks = NULL) +
    scale_y_continuous(breaks = seq(-100, 200, 20)) +
    scale_color_brewer(type = "qual", palette = "Set1") +
    facet_wrap("id") +
    rwmisc::theme_rw()
}

# run ---------------------------------------------------------------------

dat <- get_data(ids)

normals <- calc_normals(dat, year_min = year_min, year_max = year_max, min_years = 30)

normals[normals[["day_num"]] %in% 54:56, ]
filter(normals, .data$day_num %in% 54:56)

plot_daily(normals)
