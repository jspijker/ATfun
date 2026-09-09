#' Get database dirname
#'  function to determine database dirname. 
#' @returns This returns either the
#'  database path as set in ANALYSETOGETHER_DATAFOLDER environment
#'  variable, or returns default path (./data) if environment
#'  variable is not present
#' @export
#'
get_database_dirname <- function() {
  if ("ANALYSETOGETHER_DATAFOLDER" %in% names(Sys.getenv())) {
    namedir <- Sys.getenv("ANALYSETOGETHER_DATAFOLDER")
  } else {
    namedir <- file.path(here::here(), "data")
  }
  
  if(!file.exists(namedir)) {
    stop("ERROR: get_database_dirname: path to dirname not found")
  }
  return(namedir)
}

#' Get database path
#' see function get_database_dirname. This function returns the
#' full path to the database
#'
#' @param db name of database file (sqlite database file)
#'
#' @returns database path
#' @export
get_database_path <- function(db = "database.db") {
  dirname <- get_database_dirname()
  db_path <- file.path(dirname, db)
  
  if(!file.exists(db_path)) {
    log_warn("WARNING: no database found, new database created at {db_path}")
    pool <- dbPool( drv = SQLite(), dbname = db_path)
    create_database_tables(pool)
  }
  
  return(db_path)
}
