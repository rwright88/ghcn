# Snow season stats -------------------------------------------------------

library(tidyverse)
library(lubridate)
library(ghcn)

file1 <- "https://www1.ncdc.noaa.gov/pub/data/ghcn/daily/all/USW00014737.dly"

dat <- read_dly(file1) %>%
  clean_dly()

# snow by season ----------------------------------------------------------

snow_season <- function(date) {
  season_start <- if_else(
    month(date) %in% 1:6,
    year(date) - 1,
    year(date)
  )
  season_start
}

snow <- dat %>%
  mutate(season_start = snow_season(date)) %>%
  group_by(season_start) %>%
  summarise(
    n = sum(snow > 0, na.rm = TRUE),
    snow = sum(snow, na.rm = TRUE) / 25.4
  ) %>%
  ungroup()

color <- "#1f77b4"

snow %>%
  filter(season_start < max(season_start)) %>%
  ggplot(aes(season_start, snow)) +
  # geom_col(fill = "#1f77b4", alpha = 0.8) +
  geom_point(size = 2, color = color) +
  geom_smooth(method = "lm", se = FALSE, size = 1.1, color = color) +
  scale_y_continuous(limits = c(0, NA)) +
  theme_bw()

# snow per prcp -----------------------------------------------------------

dat %>%
  mutate(snow = round(snow / 25.4, 0)) %>%
  mutate(prcp = prcp / 25.4) %>%
  group_by(snow) %>%
  summarise(n = n(), snow_prcp = sum(snow) / sum(prcp)) %>%
  ungroup() %>%
  ggplot(aes(snow, snow_prcp)) +
  geom_point() +
  geom_smooth(se = FALSE) +
  theme_bw()
