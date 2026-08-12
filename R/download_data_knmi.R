#' Download the data from KNMI 
#'
#' @param x vector with the times, example c("20260501", "20260502")
#' @param station name of the station (string)
#' @param conn database connection
#'
#' @returns dataframe wirth the columns c("station", "value", "timestamp",
#' "parameter", "aggregation")
#' @export
#'
#' @examples knmi_data <- download_data_knmi_edr(c("20260501", "20260502"), "KNMI_260")
download_data_knmi <- function(x, station, conn) {
  
  ts_api <- strftime(as_datetime(x[1]), format="%Y%m%d")
  te_api <- strftime(as_datetime(x[2]), format="%Y%m%d")
  
  station_nr <- gsub(".*_", "", station)
  
  log_debug("downloading data for station {station_nr} for time range {ts_api} -  {te_api}")
  
  knmi_all <- wrap_GetKNMIAPI(station_nr, ts_api, te_api)
  
  if(is.null(knmi_all)){
    logger::log_info("downloadknmi: no connection")
    return(NULL)
  }else{  
  
    # Reshape and rename the output to long-df
    knmi_measurements <- knmi_all$data |> as.data.frame() |> 
      dplyr::select(-c('YYYYMMDD', 'HH')) |>
      rename("station" = "STNS", "wd" = "DD", "ws" = "FF", 
             "temp" = "TEMP", "rh" = "U", "timestamp" = "tijd")
    
    knmi_measurements$station <- paste0("KNMI_", knmi_measurements$station)
    
    knmi_measurements <- knmi_measurements |> 
      pivot_longer(cols = c("wd", "ws", "temp", "rh"), 
                   names_to = "parameter", 
                   values_to = "value") |>
      drop_na() |> mutate(aggregation = 3600)
    
    return(knmi_measurements)
  }
  
}

#' Wrapper around GetKNMIAPI
#' This function is a wrapper around GetKNMIAPI and includes
#' the other input variables, like token, parameter and data_result.
#'
#' see samanapir::GetKNMIAPI2 for the full info
#'
#' @param station station name
#' @param ts_api start date
#' @param te_api end date
#'
#' @returns dataframe 
#' @export
wrap_GetKNMIAPI <- function(station, ts_api, te_api) {
  return(samanapir::GetKNMIAPI2(station, ts_api, te_api))
}
