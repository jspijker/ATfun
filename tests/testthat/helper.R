# Helper functions
#######################################################################
list_doc_types <- function(conn) {
    # List the distinct types of documents in the database, it returns
    # a character vector with the types.
    # arguments
    # conn: database connection

    qry <- glue::glue_sql("SELECT DISTINCT type FROM meta;",
                          .con = conn)
    res <- DBI::dbGetQuery(conn, qry) |>
        dplyr::pull(type)
    return(res)

}


list_doc_all <- function(conn) {
    # List all types and rerences from the meta table.
    # arguments
    # conn: database connection

    qry <- glue::glue_sql("SELECT type,ref FROM meta;",
                          .con = conn)
    res <- DBI::dbGetQuery(conn, qry)
    return(res)

}

reset_db <- function(fname) {
    # removes the current database and creates a new one with the same
    # name
    # arguments:
    # fname: name of the database file (usually a temporary file)
    # return value:
    # true if database was reset, false if not
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


