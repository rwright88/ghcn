# annually

library(tidyverse)
library(lubridate)
library(ghcn)

source("other/utils.R")

id <- "USW00014711"

# funs --------------------------------------------------------------------

ann_mean <- function(x, days_min = 360) {
  days_notna <- sum(!is.na(x))

  if (days_notna >= days_min) {
    out <- mean(x, na.rm = TRUE)
  } else {
    out <- return(NA_real_)
  }

  out
}

calc_annually <- function(data) {
  anually <- data %>%
    group_by(year = lubridate::year(date)) %>%
    summarise(
      tmax = ann_mean(tmax),
      tmin = ann_mean(tmin)
    ) %>%
    ungroup()

  anually
}

plot_annually_temps <- function(data) {
  data <- gather(data, "var", "value", tmax, tmin)
  y_range <- range(data$value, na.rm = TRUE)
  y_min <- y_range[1] - diff(y_range) * 0.1
  y_max <- y_range[2] + diff(y_range) * 0.1

  data %>%
    ggplot(aes(year, value, color = var)) +
    geom_point() +
    geom_smooth(method = "loess", span = 1, se = FALSE, size = 0.5) +
    scale_y_continuous(limits = c(y_min, y_max)) +
    scale_color_brewer(type = "qual", palette = "Set1") +
    theme_bw()
}

# run ---------------------------------------------------------------------

dat <- read_dly(id)

dat <- clean_dly(dat) %>%
  mutate_at(c("prcp", "snow", "snwd"), mmtoin) %>%
  mutate_at(c("tmax", "tmin"), ctof)

dat %>%
  filter(date < today()) %>%
  arrange(desc(date))

anually <- calc_annually(dat)

plot_annually_temps(anually)
