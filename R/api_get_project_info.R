#' gets project info from the API Samen Meten 
#'
#' @param project string name of the project
#' @param conn db connection object
#'
#' @returns list with c("sensor_data", "datastream_data")
#' @export
#'
api_get_project_info <- function(project, conn) {

    logger::log_debug(paste0("getting project info for ", project))
    projectinfo <- wrap_GetSamenMetenAPIinfoProject(project)
    ATdatabase::add_doc("project", project, projectinfo,
            conn = conn, overwrite = TRUE)
    return(projectinfo)
}

#' Wrapper around GetSamenMetenAPIinfoProject
#' This function is a wrapper around samanapir::GetSamenMetenAPIinfoProject
#' mostly for testing
#' 
#' See samanapir::GetSamenMetenAPIinfoProject, for more info
#' 
#' @param project project name
#'
#' @returns list
#' @export
# create wrapper for samanapir function to allow for testing
wrap_GetSamenMetenAPIinfoProject <- function(project) {
    return(samanapir::GetSamenMetenAPIinfoProject(project))
}
