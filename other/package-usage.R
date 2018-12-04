# -------------------------------------------------------------------------
#
# Script to count package usage and dependencies.
#
# -------------------------------------------------------------------------

library(tidyverse)
library(tools)
library(desc)

dir1 <- "R"

# funs --------------------------------------------------------------------

#' Count number of function calls per file per package.
#'
#' @param dir Directory of R files.
#' @return Data frame.
count_calls <- function(dir) {
  files <- list.files(dir, "\\.[R]$", full.names = TRUE, ignore.case = TRUE)
  lines <- map(files, read_lines)

  deps <- desc::desc_get_deps() %>%
    filter(type == "Imports")
  calls <- str_c(deps[["package"]], "::")

  n_calls <- vector("list", length(calls))
  names(n_calls) <- calls

  for (call in calls) {
    n_calls[[call]] <- map_int(lines, ~sum(str_count(., call)))
  }

  n_calls <- as_tibble(n_calls) %>%
    mutate(file = files)

  n_calls
}

get_deps_rec <- function() {
  by_package <- desc::desc_get_deps() %>%
    filter(type == "Imports") %>%
    .[["package"]] %>%
    tools::package_dependencies(recursive = TRUE)

  combined <- sort(unique(flatten_chr(by_package)))

  list(
    "by_package" = by_package,
    "combined"   = combined
  )
}

# run ---------------------------------------------------------------------

count_calls(dir1)

str(get_deps_rec())
