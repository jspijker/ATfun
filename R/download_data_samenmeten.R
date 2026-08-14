download_data_samenmeten <- function(x, station, conn) {

    streaminfo <- ATdatabase::get_doc(type = "datastream", ref = station, conn)
    if (length(streaminfo) == 1 && is.na(streaminfo)) {
        logger::log_warn("download_data_samenmeten: datastream {station} is empty")
        return(NULL)
    } else {
        streams <- streaminfo |>
            dplyr::pull(datastream_id)
    }

    ts_api <- strftime(lubridate::as_datetime(x[1]), format = "%Y%m%d")
    te_api <- strftime(lubridate::as_datetime(x[2]), format = "%Y%m%d")

    logger::log_debug("downloading data for station {station} for time range {ts_api} -  {te_api}")

    d <- data.frame()

    errors <- 0 # Error counter, how many streams returned an error
    api_success <- FALSE # Flag to indicate if at least one API call was successful


    for (i in streams) {
        res <- try(obs <- wrap_GetSamenMetenAPIobs(as.character(i),
                                                   station, ts_api, te_api))

        if (inherits(res, "try-error")) {
            logger::log_warn("download_data_samenmeten: error in API call {station} - {i}")
            obs <- NULL 
        }

        if (!is.null(obs)) {
            if (nrow(obs) > 0) {
                d <- dplyr::bind_rows(d, obs)
            }
        } else {
            errors <- errors + 1
        }
    }


    if (errors == length(streams)) {
        logger::log_warn("download_data_samenmeten: all streams for station {station} returned an error")
        d <- NULL
    }

    if (!is.null(d) && nrow(d) > 0) {
        d <- d  |>
            rename(station = kit_id) |>
            mutate(aggregation = 3600)
        logger::log_debug("got {ifelse(is.null(d),'no',nrow(d))} measurements")
    } else {
        logger::log_warn("download_data_samenmeten: no data received for station {station} in time range {ts_api} -  {te_api}")
            }
    return(d)
}


wrap_GetSamenMetenAPIobs <- function(stream, station, ts_api, te_api) {
    x <- samanapir::GetSamenMetenAPIobs2(stream, station, ts_api, te_api)
    return(x)
}
