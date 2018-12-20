# -------------------------------------------------------------------------
#
# Script to count package usage.
#
# -------------------------------------------------------------------------

library(tidyverse)
library(desc)

dir1 <- "R"

# funs --------------------------------------------------------------------

count_calls <- function(dir) {
  files <- list.files(dir, "\\.[R]$", full.names = TRUE, ignore.case = TRUE)
  lines <- map(files, read_lines)

  deps <- desc::desc_get_deps() %>%
    filter(type == "Imports")

  calls <- str_c(deps[["package"]], "::")

  if ("magrittr::" %in% calls) {
    calls <- c(calls, "%>%")
  }

  n_calls <- vector("list", length(calls))
  names(n_calls) <- calls

  for (call in calls) {
    n_calls[[call]] <- map_int(lines, ~sum(str_count(., call)))
  }

  n_calls <- as_tibble(n_calls) %>%
    mutate(file = files) %>%
    select(file, everything())

  n_calls
}

# run ---------------------------------------------------------------------

count_calls(dir1)
