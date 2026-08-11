#' Set loglevel
#' function to set the loglevel in the Analyse together tool,
#' using logger
#' 
#'
#' @param level default "info" (options used: DEBUG, TRACE, INFO)
#'
#' @returns no return value
#' @export
#'
set_loglevel <- function(level = "INFO") {
  
  if ("ANALYSETOGETHER_LOGLEVEL" %in% names(Sys.getenv())) {
    loglevel <- Sys.getenv("ANALYSETOGETHER_LOGLEVEL")
  } else {
    loglevel <- level
  }
  
  log_threshold(loglevel)
  log_warn(glue::glue("Loglevel set at {loglevel}"))
  
  invisible(level)
}
