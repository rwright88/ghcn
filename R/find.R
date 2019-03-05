#' Find stations that match pattern
#'
#' @param pattern Character string of length one to match station names.
#' @return Data frame of station data.
#' @export
ghcn_find_stations <- function(pattern) {
  if (length(pattern) != 1) {
    stop("`Pattern` must have length of 1.", call. = FALSE)
  }
  out <- ghcn_read_stations()
  out <- out[grepl(pattern, out$name, ignore.case = TRUE, perl = TRUE), ]
  out
}
