#' Download location of KNMI station
#'
#' @param knmi_station string with number of station (e.g. "KNMI_260")
#' @param time_start string with start time (posixct)
#' @param time_end string with end time (posixct)
#'
#' @returns dataframe(station (string), lat (numeric), lon(numeric))
#' @export
#'
#' @examples download_location_knmi("KNMI_260",
#' as_datetime("2022-01-01 00:00:00"),
#' as_datetime("2022-01-08 23:59:59") )
download_locations_knmi <- function(knmi_stations, time_start, time_end) {
  
  station_nr <- gsub(".*_", "", knmi_stations)
  
  knmi_stations_all <- wrap_GetKNMIAPI(station_nr,
                                             format(time_start, '%Y%m%d'), 
                                             format(time_end, '%Y%m%d'))
  if(is.null(knmi_stations_all)){
    logger::log_info("downloadknmi: no connection")
    return(NULL)
  }else{
    knmi_stations_locations <- knmi_stations_all$info  |> 
      as.data.frame()  |> 
      select(c("STNS", "LAT", "LON"))  |> 
      rename("station" = "STNS", "lat" = "LAT", "lon" = "LON") |>
      drop_na() |>
      mutate(lat = as.numeric(lat)) |>
      mutate(lon = as.numeric(lon)) |>
      mutate(station = paste0("KNMI_", station))
    
    return(knmi_stations_locations)
  }
}
