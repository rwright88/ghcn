#' Find stations that match pattern
#'
#' @param pattern Character string of length one to match station names.
#' @return Data frame of station data.
#' @export
ghcn_find_stations <- function(pattern) {
  stopifnot(length(pattern) == 1)
  out <- ghcn_read_stations()
  out[grepl(pattern, out$name, ignore.case = TRUE, perl = TRUE), ]
}
