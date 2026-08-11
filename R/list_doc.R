#' List all documents of specific type
#'
#' @param type string with type of document to list
#' @param conn database connection
#'
#' @returns list of references with that type
#' @export
#'
list_doc <- function(type, conn) {
  qry <- glue::glue_sql("SELECT ref FROM meta WHERE type={type};",
                        .con = conn)
  res <- DBI::dbGetQuery(conn, qry)
  return(res$ref)
  
}
