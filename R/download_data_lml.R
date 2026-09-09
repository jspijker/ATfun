#' Download the data from Luchtmeetnet 
#'
#' @param x vector with the times, example c("20260501", "20260502")
#' @param station name of the station (string)
#'
#' @returns dataframe wirth the columns ("station", "value", "timestamp", 
#' "parameter", "timestamp_measured_start", "timestamp_measured_end", "aggregation"))
#' @export
#'
#' @examples 
#' \dontrun{lml_data <- download_data_lml(c("20260501", "20260502"), "NL49680")}
download_data_lml <- function(x, station) {

    ts_api <- strftime(lubridate::as_datetime(x[1]), format = "%Y%m%d")
    te_api <- strftime(lubridate::as_datetime(x[2]), format = "%Y%m%d")

    logger::log_debug("downloading data for station {station} for time range {ts_api} -  {te_api}")

    lml_data <- wrap_GetLMLstatdataAPI(station, ts_api, te_api)

    logger::log_debug("got {nrow(lml_data} rows from LML API")

    if (length(lml_data) == 0) {
        # Return empty dataframe if station returns no data

        lml_data <- data.frame(matrix(ncol = 5, nrow = 0))
        colnames(lml_data) <- c("station", "value", "timestamp", 
                                "parameter", "aggregation")
    } else {
        lml_data <- lml_data |>
            dplyr::rename("station" = "station_number", 
                          "timestamp" = "timestamp_measured", 
                          "parameter" = "formula") |>
            tidyr::drop_na() |>
            dplyr::mutate(aggregation = 3600) |>
            dplyr::mutate(parameter = tolower(parameter))
    }
    return(lml_data)
}


#' Wrapper around GetLMLstatdataAPI2
#' This function is a wrapper around GetLMLstatdataAPI2 and includes
#' the other input variables, like token, parameter and data_result.
#'
#' see samanapir::GetLMLstatdataAPI2 for the full info
#'
#' @param station station name
#' @param ts_api start date
#' @param te_api end date
#'
#' @returns dataframe 
wrap_GetLMLstatdataAPI <- function(station, ts_api, te_api) {
    return(samanapir::GetLMLstatdataAPI2(station, ts_api, te_api))
}
