# Snow season stats -------------------------------------------------------

library(tidyverse)
library(lubridate)
library(ghcn)

source("other/utils.R")

stations <- read_stations()

res <- find_stations("Richmond")
id <- "USW00013740"

dat <- read_dly(id) %>%
  clean_dly() %>%
  mutate_at(c("prcp", "snow", "snwd"), mmtoin) %>%
  mutate_at(c("tmax", "tmin"), ctof)

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
    snow = sum(snow, na.rm = TRUE)
  ) %>%
  ungroup()

color <- "#1f77b4"

snow %>%
  filter(season_start < max(season_start)) %>%
  ggplot(aes(season_start, snow)) +
  geom_point(size = 2, color = color) +
  geom_smooth(method = "lm", se = FALSE, size = 0.5, color = color) +
  scale_y_continuous(limits = c(0, NA)) +
  theme_bw()

# other -------------------------------------------------------------------

dat %>%
  filter(year(date) == max(year(date))) %>%
  select(date, tmax, tmin) %>%
  gather("type", "temp", tmax, tmin) %>%
  ggplot(aes(date, temp, color = type)) +
  geom_point() +
  scale_x_date(date_breaks = "2 months") +
  scale_y_continuous(breaks = seq(-100, 200, 20)) +
  scale_color_brewer(type = "qual", palette = "Set1") +
  theme_bw()
