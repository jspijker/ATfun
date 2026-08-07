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
    knmi_measurements <- knmi_all$data %>% as.data.frame() %>% 
      dplyr::select(-c('YYYYMMDD', 'HH')) %>%
      rename("station" = "STNS", "wd" = "DD", "ws" = "FF", 
             "temp" = "TEMP", "rh" = "U", "timestamp" = "tijd")
    
    knmi_measurements$station <- paste0("KNMI_", knmi_measurements$station)
    
    knmi_measurements <- knmi_measurements %>% 
      pivot_longer(cols = c("wd", "ws", "temp", "rh"), 
                   names_to = "parameter", 
                   values_to = "value") %>%
      drop_na() %>% mutate(aggregation = 3600)
    
    return(knmi_measurements)
  }
  
}

wrap_GetKNMIAPI <- function(station, ts_api, te_api) {
  return(samanapir::GetKNMIAPI(station, ts_api, te_api))
}