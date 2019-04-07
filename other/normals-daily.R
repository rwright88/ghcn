# daily climate normals
# https://www.ncdc.noaa.gov/cdo-web/datatools/normals

library(tidyverse)
library(lubridate)
library(ghcn)

ids <- c(
  "Allentown"  = "USW00014737",
  "Harrisburg" = "USW00014711",
  "Richmond"   = "USW00013740",
  "San Diego"  = "USW00023188"
)

year_min  <- 1981
year_max  <- 2010

# funs --------------------------------------------------------------------

get_data <- function(ids) {
  data <- map_dfr(ids, ghcn_read)
  data <- ghcn_clean(data)
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
  if (anyNA(x)) {
    return(NA)
  } else {
    predict(loess(x ~ day, span = 0.3))
  }
}

calc_normals <- function(data, year_min, year_max, min_years) {
  data <- data %>%
    mutate(year = year(date)) %>%
    filter(year %in% year_min:year_max, !(month(date) == 2 & day(date) == 29)) %>%
    arrange(id, date) %>%
    group_by(id, year) %>%
    mutate(day_num = yday(date)) %>%
    ungroup()

  leap <- (leap_year(data$date) & (month(data$date) > 2))
  data$day_num[leap] <- data$day_num[leap] - 1

  normals <- data %>%
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

normals <- calc_normals(dat, year_min = year_min, year_max = year_max, min_years = 20)

normals %>%
  filter(id == "Allentown") %>%
  plot_daily()
