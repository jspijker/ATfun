# this function downloads a set of sensors belonging to either a
# project or municipality,  download the station meta data, and
# downloads the measurements for the requested time range
# The type arguments determine if data is requested for a
# municpality or a project.
# arguments:
#    name: name of project or municipality
#    type: either 'project' or 'municipality'
#    conn: db connection object


#' Download meta data sensor Samen Meten
#' This function downloads a set of sensors belonging to either a
#' project or municipality,  download the station meta data, and 
#' downloads the measurements for the requested time range
#' The type arguments determine if data is requested for a
#' municpality or a project.
#' @param name name of project or municipality
#' @param type either 'project' or 'municipality'
#' @param conn db connection object
#'
#' @returns df with the columns c("station", "parameter", 
#' "timestamp", "value", "aggregation")
#' @export 
#'
# @examples  download_sensor_meta("Amersfoort", type = "municipality", conn = dbconn)
download_sensor_meta <- function(name, type, conn) {

    switch(type,
           project = {
               projinfo <- api_get_project_info(name, conn = conn)
           },
           municipality = {
               projinfo <- api_get_municipality_info(name, conn = conn)
           },
           { #unknown type
               stop("download_sensor_meta: unknown type")
           })

    stations <- projinfo$sensor_data |>
        dplyr::select(kit_id, lat, lon) |>
        tibble::as_tibble()

    sensors_meta <- projinfo$sensor_data |>
        dplyr::select(-lat, -lon) |>
        tibble::as_tibble()

    logger::log_debug(paste("Got", nrow(stations), "stations for project", name))
    apply(stations, 1, FUN  = insert_location_info_vectorized, conn = conn)
    apply(sensors_meta, 1, FUN=store_sensor_vectorized, conn = conn)

    datastreams <- projinfo$datastream_data

    for(i in unique(datastreams$kit_id)) {
        kit <- datastreams |>
            dplyr::filter(kit_id == i) |>
            dplyr::select(-kit_id)


        type <- "datastream"
        if(!doc_exists(type, ref = i, conn = conn)) {
            logger::log_trace("storing stream data info for {i}")
            add_doc(type, ref = i, doc = kit, conn = conn)
        } else {
            logger::log_trace("skipping store stream data info for {i}")

        }
    }
}

#--
# vectorized helper functions
#--

insert_location_info_vectorized <- function(x, conn = conn) {
    kit <- x |>
        tibble::as_tibble_row() |>
        dplyr::mutate(lat = as.numeric(lat)) |>
        dplyr::mutate(lon = as.numeric(lon))
    logger::log_trace("storing location info for {kit$kit_id}")
    insert_location_info(station = kit$kit_id,
                         lat = kit$lat,
                         lon = kit$lon,
                         conn)
}

store_sensor_vectorized <- function(x, type = "station", conn = conn) {

    ref <- x[["kit_id"]]
    doc <- x |>
        tibble::as_tibble_row()
    if(!doc_exists(type, ref, conn = conn)) {
        logger::log_trace("storing meta data info for {ref}")
        add_doc(type, ref, doc, conn = conn)
    } else {
        logger::log_trace("skipping store meta data info for {ref}")
    }

}
