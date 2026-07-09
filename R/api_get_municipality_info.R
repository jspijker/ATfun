
api_get_municipality_info <- function(municipality, conn) {
    # gets municipality info from the API
    # arguments:
    #   municipality: name of the municipality

    gemid <- municipalities |>
          dplyr::filter(name == municipality) |>
          dplyr::pull(code) |>
          as.character()

    logger::log_debug(paste0("getting municipality info for ", municipality))
    muni_info <- wrap_GetSamenMetenAPIinfoMuni(gemid)
    add_doc("municipality", municipality, muni_info,
            conn = conn, overwrite = TRUE)
    return(muni_info)
}

wrap_GetSamenMetenAPIinfoMuni <- function(gemid) {
    # wrapper around samanapir::GetSamenMetenAPIinfoMuni
    # arguments:
    #   gemid: municipality code
    muni_info <- samanapir::GetSamenMetenAPIinfoMuni(gemid)
    return(muni_info)
}

