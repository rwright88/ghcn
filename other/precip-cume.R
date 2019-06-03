# cumulative precipitation by day per year

library(tidyverse)
library(lubridate)
library(ghcn)

ids <- c(
  "Allentown"    = "USW00014737",
  "Harrisburg"   = "USW00014711",
  "Harrisburg2"  = "USW00014751",
  "Philadelphia" = "USW00013739"
)

years <- 1989:2019
years_mean <- 1989:2018

# funs --------------------------------------------------------------------

get_data <- function(ids, element = c("prcp", "snow"), years) {
  element <- match.arg(element)
  data <- map_dfr(ids, ghcn_read)
  data <- ghcn_clean(data)
  data <- data[, c("id", "date", element)]
  data$id <- names(ids)[match(data$id, ids)]
  data[[element]] <- data[[element]] / 25.4
  data$year <- year(data$date)
  data <- data[data$year %in% years, ]

  # fix harrisburg
  data <- data %>%
    mutate(id = ifelse(year(date) %in% 1968:1991 & id == "Harrisburg2", "Harrisburg", id)) %>%
    filter(id != "Harrisburg2")

  data
}

calc_cume_year <- function(data) {
  out <- data %>%
    filter(date < today()) %>%
    arrange(id, date) %>%
    group_by(id, year) %>%
    mutate(day_num = rank(date, na.last = "keep", ties.method = "first")) %>%
    mutate(cume = cumsum(prcp)) %>%
    ungroup() %>%
    filter(day_num != 366)

  bad <- out[which(out$day_num == 1 & month(out$date) != 1), ]

  for (i in seq_len(nrow(bad))) {
    id <- bad$id[i]
    year <- bad$year[i]
    out <- out[!(out$id == id & out$year == year), ]
  }

  out$year <- as.character(out$year)
  out
}

calc_cume_mean <- function(data, years) {
  out <- data %>%
    filter(year %in% years) %>%
    group_by(id, day_num) %>%
    summarise(cume = mean(cume)) %>%
    ungroup() %>%
    mutate(year = "mean")

  out
}

plot_cume <- function(data) {
  year_max <- max(data$year[data$year != "mean"])
  breaks <- c(1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335)
  labels <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

  data %>%
    ggplot(aes(day_num, cume, group = year)) +
    geom_line(size = 0.5, alpha = 0.2) +
    geom_line(
      data = data[data$year == "mean", ],
      mapping = aes(day_num, cume),
      size = 1,
      color = "#E41A1C"
    ) +
    geom_line(
      data = data[data$year == year_max, ],
      mapping = aes(day_num, cume),
      size = 1,
      color = "#377EB8"
    ) +
    facet_wrap("id") +
    scale_x_continuous(breaks = breaks, labels = labels, minor_breaks = NULL) +
    labs(
      x = "Date",
      y = "Cumulative rainfall (inches)"
    ) +
    theme_bw()
}

# run ---------------------------------------------------------------------

data <- get_data(ids, element = "prcp", years = years)

cume_year <- calc_cume_year(data)
cume_mean <- calc_cume_mean(cume_year, years = years_mean)
cume <- bind_rows(cume_year, cume_mean)

plot_cume(cume)
