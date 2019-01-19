# -------------------------------------------------------------------------
#
# Script to calculate snow season stats.
#
# -------------------------------------------------------------------------

library(tidyverse)
library(lubridate)
library(ghcn)

source("other/utils.R")

id <- "USW00014711"

# funs --------------------------------------------------------------------

get_snow_yearly <- function(data) {
  snow <- data %>%
    mutate(season_start = case_when(
      month(date) %in% 1:6 ~ year(date) - 1,
      TRUE ~ year(date)
    )) %>%
    mutate(snow = mmtoin(snow)) %>%
    group_by(season_start) %>%
    summarise(
      n = sum(snow > 0, na.rm = TRUE),
      snow = sum(snow, na.rm = TRUE)
    ) %>%
    ungroup()

  snow
}

plot_snow <- function(data) {
  data %>%
    filter(season_start < max(season_start)) %>%
    ggplot(aes(season_start, snow)) +
    geom_point(size = 2, color = "#1f77b4") +
    geom_line(size = 0.5, color = "#1f77b4") +
    scale_x_continuous(breaks = seq(1800, 2100, 20)) +
    scale_y_continuous(limits = c(0, NA)) +
    theme_bw()
}

# run ---------------------------------------------------------------------

dat <- read_dly(id) %>%
  clean_dly()

snow_yearly <- get_snow_yearly(dat)

plot_snow(snow_yearly)
