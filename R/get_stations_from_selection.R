#' Get station identifiers from a stored selection
#'
#' Retrieves station identifiers for a stored project or municipality
#' document in the database. The result combines sensor kit ids, KNMI
#' station ids, and reference station ids from particulate matter
#' columns.
#'
#' @param name Name of the project or municipality.
#' @param type Selection type. Must be either `"project"` or
#'   `"municipality"`.
#' @param conn Database connection object.
#'
#' @return A character vector of station identifiers. Returns `NULL` if
#'   no matching document exists.
#'
#' @examples
#' \dontrun{
#' stations <- get_stations_from_selection(
#'   name = "Amersfoort",
#'   type = "municipality",
#'   conn = dbconn
#' )
#' }
#'
#' @export
get_stations_from_selection <- function(name, type, conn = pool) {

  info <- switch(
    type,
    project = {
      ATdatabase::get_doc(type = "project", ref = name, conn = conn)
    },
    municipality = {
      ATdatabase::get_doc(type = "municipality", ref = name, conn = conn)
    },
    {
      stop("download_sensor_meta: unknown type")
    }
  )

  if (!is.list(info)) {
    return(NULL)
  }

  sensors <- info$sensor_data |>
    dplyr::pull(kit_id)

  knmi <- info$sensor_data |>
    dplyr::pull(knmicode) |>
    unique() |>
    sub("knmi_06", "KNMI_", .)

  ref_station <- info$sensor_data |>
    dplyr::select(dplyr::starts_with("pm")) |>
    tidyr::pivot_longer(
      cols = dplyr::starts_with("pm"),
      names_to = "stat"
    ) |>
    dplyr::pull(value) |>
    unique()

  stations <- c(sensors, knmi, ref_station)

  return(stations)
}
