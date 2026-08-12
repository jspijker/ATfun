#' Reset db
#' removes the current database and creates a new one with the same
#' @param fname  name of the database file (usually a temporary file)
#' @export
#' @returns true if database was reset, false if not
reset_db <- function(fname) {
  return_value <- FALSE
  if (file.exists(fname)) {
    file.remove(fname)
    return_value <- TRUE
  }
  dbconn <- pool::dbPool(drv = RSQLite::SQLite(),
                         dbname = fname)
  
  ATdatabase::create_database_tables(dbconn)
  
  # diconnect pool db object
  pool::poolClose(dbconn)
  return(return_value)
}
