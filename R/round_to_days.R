#' Round to days
#'   the samen meten API requires time ranges in full days. This
#'   function rounds any time to the start of the day of time_start
#'   until the end of the day of time_end
#' @param time_start string with start time (POSIXct)
#' @param time_end string with end time (POSIXct)
#'
#' @returns c("time_start","time_end") with values rounded by day
#' @export
#'
#' @examples
#' time_start <- as_datetime("2022-01-01 00:00:00")
#' time_end <- as_datetime("2022-01-08 23:59:59")
#' round_to_days(time_start, time_end)
round_to_days <- function(time_start, time_end) {

  ts <- floor_date(time_start, unit = "day")
  te <- ceiling_date(time_end, unit = "day")
  
  if(!te>ts) {
    te <- te + days(1)
  }
  
  if(te<=ts) {
    stop("te < ts")
  }
  res <- c(ts, te)
  names(res) <- c("time_start","time_end")
  
  return(res)
}
