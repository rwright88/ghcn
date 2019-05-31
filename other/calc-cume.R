# cumulative snow by day per year

library(tidyverse)
library(lubridate)
library(ghcn)

ids <- c(
  "Allentown"    = "USW00014737",
  "Harrisburg"   = "USW00014711",
  "Harrisburg2"  = "USW00014751",
  "Philadelphia" = "USW00013739"
)

# funs --------------------------------------------------------------------

get_data <- function(ids) {
  data <- map_dfr(ids, ghcn_read)
  data <- ghcn_clean(data)
  data <- data[c("id", "date", "snow")]
  data$id <- names(ids)[match(data$id, ids)]
  data
}

rec_season_start <- function(date) {
  p1 <- (month(date) %in% 7:12)
  p2 <- (month(date) %in% 1:6)
  out <- rep(NA_integer_, length(date))
  out[p1] <- year(date[p1])
  out[p2] <- year(date[p2]) - 1
  out
}

calc_cume_snow <- function(data) {
  data$snow[is.na(data$snow)] <- 0

  cume <- data %>%
    filter(date < today()) %>%
    mutate(season_start = rec_season_start(date)) %>%
    mutate(snow = snow / 25.4) %>%
    arrange(id, date) %>%
    group_by(id, season_start) %>%
    mutate(day_num = row_number(date)) %>%
    mutate(snow_cume = cumsum(snow)) %>%
    ungroup()

  bad <- cume %>%
    filter(day_num == 1, month(date) != 7)

  for (i in seq_len(nrow(bad))) {
    id1 <- bad$id[i]
    ss1 <- bad$season_start[i]
    cume <- filter(cume, !(id == id1 & season_start == ss1))
  }

  cume
}

calc_cume_mean <- function(data, years) {
  means <- data %>%
    filter(season_start %in% years) %>%
    group_by(id, day_num) %>%
    summarise(snow_cume = mean(snow_cume)) %>%
    ungroup() %>%
    mutate(season_start = "mean")

  means
}

plot_cume <- function(data) {
  breaks <- c(1, 32, 63, 93, 124, 154, 185, 216, 244, 275, 305, 336)
  labels <- c("Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "Jan", "Feb", "Mar", "Apr", "May", "Jun")

  data %>%
    ggplot(aes(day_num, snow_cume, group = season_start)) +
    geom_line(size = 0.5, alpha = 0.2) +
    geom_line(
      data = filter(data, season_start == "mean"),
      mapping = aes(day_num, snow_cume),
      size = 1,
      color = "#E41A1C"
    ) +
    geom_line(
      data = filter(data, season_start == "2018"),
      mapping = aes(day_num, snow_cume),
      size = 1,
      color = "#377EB8"
    ) +
    labs(
      x = "Date",
      y = "Cumulative snowfall (inches)"
    ) +
    scale_x_continuous(breaks = breaks, labels = labels, minor_breaks = NULL) +
    scale_y_continuous(breaks = seq(0, 1000, 20)) +
    facet_wrap("id") +
    theme_bw()
}

# run ---------------------------------------------------------------------

dat <- get_data(ids)

# temp fix, 1991 and 1992?
dat <- dat %>%
  mutate(id = ifelse(year(date) %in% 1968:1991 & id == "Harrisburg2", "Harrisburg", id)) %>%
  filter(id != "Harrisburg2")

cume_snow <- calc_cume_snow(dat)

cume_mean <- calc_cume_mean(cume_snow, years = 1968:2017)

cume_snow %>%
  mutate(season_start = as.character(season_start)) %>%
  bind_rows(cume_mean) %>%
  filter(day_num %in% 93:305, season_start %in% c("mean", as.character(1968:2018))) %>%
  plot_cume()
