# Testing -----------------------------------------------------------------

library(tidyverse)
library(ghcn)

dir1 <- "../../data/ghcn/ghcnd_gsn"

# benchmark and size ------------------------------------------------------

n <- 500
files <- fs::dir_ls(dir1)
files <- files[sample(n)]

f1 <- function(files) {
  data <- map_dfr(files, ~clean_dly(read_dly(.)))
  data
}

f2 <- function(files) {
  data <- map_dfr(files, read_dly)
  data <- clean_dly(data)
  data
}

system.time(dly1 <- f1(files))
system.time(dly2 <- f2(files))

all.equal(
  arrange(dly1, date),
  arrange(dly2, date)
)
summary(dly1)
lobstr::obj_size(dly1) / n
