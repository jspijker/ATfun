#' Check if station in database exists
#' checks if 'station' already exists in the location table
#' 
#' @param station string name of station
#' @param conn database connection
#'
#' @returns TRUE of FALSE
#' @export
station_exists <- function(station, conn) {
  # checks if 'station' allready exists in the location table
  
  if(length(station) != 1) {
    stop("ERROR station_exists, length(station)!=1")
  }
  
  qry <- glue::glue_sql("select station from location where station = {station};", 
                        .con = conn)
  res <- dbGetQuery(conn, qry)
  
  if(nrow(res)>=1) {
    result <- TRUE
  } else {
    result <- FALSE
  }
  
  return(result)
  
}
