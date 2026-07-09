
api_get_project_info <- function(project, conn) {
    # gets project info from the API
    # arguments:
    #   project: name of the project
    #   conn: db connection object

    logger::log_debug(paste0("getting project info for ", project))
    projectinfo <- wrap_GetSamenMetenAPIinfoProject(project)
    ATdatabase::add_doc("project", project, projectinfo,
            conn = conn, overwrite = TRUE)
    return(projectinfo)
}

# create wrapper for samanapir function to allow for testing
wrap_GetSamenMetenAPIinfoProject <- function(project) {
    return(samanapir::GetSamenMetenAPIinfoProject(project))
}


