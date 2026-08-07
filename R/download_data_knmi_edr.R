download_data_knmi_edr <- function(x, station, conn) {
  
  ts_api <- strftime(as_datetime(x[1]), format="%Y%m%d")
  te_api <- strftime(as_datetime(x[2]), format="%Y%m%d")
  
  station_nr <- gsub(".*_", "", station)
  
  log_debug("downloading data for station {station_nr} for time range {ts_api} -  {te_api}")

  knmi_all <- wrap_GetKNMIAPIEDR(station_nr, ts_api, te_api)

  # Check the result of API and adjust
  if(is.null(knmi_all)){
    logger::log_info("downloadknmiedr: no connection")
    return(NULL)
  }else if(length(knmi_all) == 0){
    logger::log_info("downloadknmiedr: no data")
    # Return empty dataframe if station returns no data
    knmi_measurements <- data.frame(matrix(ncol = 5, nrow = 0))
    colnames(knmi_measurements) <- c("station", "value", "timestamp",
                                     "parameter", "aggregation")
    return()
  }else{
    knmi_measurements <- knmi_all |> dplyr::mutate(
      parameter = case_when(parameter_name == "ffs" ~ "ws",
                            parameter_name == "dd" ~ "wd"), 
      station = paste0("KNMI_", id_nr),
      timestamp = date_time,
      aggregation = 3600,
      value = values
    ) |> dplyr::select(c(parameter, station, timestamp, aggregation, value))
  
    return(knmi_measurements)
  }
  
}

wrap_GetKNMIAPIEDR <- function(station, ts_api, te_api) {
  return(samanapir::GetKNMIAPIEDR(date_start = ts_api,
                                  date_end = te_api, 
                                  token = Sys.getenv("KNMI_API_TOKEN"),
                                  location_id = station, 
                                  parameter = "wind",
                                  data_result = "hourly"))
}