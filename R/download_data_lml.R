
download_data_lml <- function(x, station) {

    ts_api <- strftime(lubridate::as_datetime(x[1]), format = "%Y%m%d")
    te_api <- strftime(lubridate::as_datetime(x[2]), format = "%Y%m%d")

    logger::log_debug("downloading data for station {station} for time range {ts_api} -  {te_api}")

    lml_data <- wrap_GetLMLstatdataAPI(station, ts_api, te_api)

    logger::log_debug("got {nrow(lml_data} rows from LML API")

    if (length(lml_data) == 0) {
        # Return empty dataframe if station returns no data

        lml_data <- data.frame(matrix(ncol = 5, nrow = 0))
        colnames(lml_data) <- c("station", "value", "timestamp", "parameter", "aggregation")
    } else {
        lml_data <- lml_data |>
            dplyr::rename("station" = "station_number", "timestamp" = "timestamp_measured", "parameter" = "formula") |>
            tidyr::drop_na() |>
            dplyr::mutate(aggregation = 3600) |>
            dplyr::mutate(parameter = tolower(parameter))
    }
    return(lml_data)
}


wrap_GetLMLstatdataAPI <- function(station, ts_api, te_api) {
    return(samanapir::GetLMLstatdataAPI(station, ts_api, te_api))
}
