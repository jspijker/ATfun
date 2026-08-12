#' Download location of KNMI station (using edr api)
#'
#' @param knmi_station string with number of station (e.g. "KNMI_260")
#' @param time_start string with start time (posixct)
#' @param time_end string with end time (posixct)
#'
#' @returns dataframe(station (string), lat (numeric), lon(numeric))
#' @export
#'
#' @examples download_location_knmi_edr("KNMI_260",
#' lubridate::as_datetime("2022-01-01 00:00:00"),
#' lubridate::as_datetime("2022-01-08 23:59:59") )
download_location_knmi_edr <- function(knmi_station, time_start, time_end) {
  station_nr <- gsub(".*_", "", knmi_station)
  
  knmi_stations_all <- wrap_GetKNMIAPIEDR(station_nr, format(time_start, '%Y%m%d'), 
                                             format(time_end, '%Y%m%d'))
  if(is.null(knmi_stations_all)){
    logger::log_info("downloadknmi: no connection")
    return(NULL)
  }else{
    knmi_stations_locations <- knmi_stations_all |> 
      select(c("id_nr", "lat", "lon"))  |> 
      rename("station" = "id_nr") |>
      drop_na() |>
      mutate(station = paste0("KNMI_", station)) 
    
    knmi_stations_locations <- knmi_stations_locations[1,]
    
    return(knmi_stations_locations)
  }
}
