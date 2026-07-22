# make sure we start with a clean database
reset_db(fname_db)
dbconn <- pool::dbPool(
  drv = RSQLite::SQLite(),
  dbname = fname_db
)

local_mocked_bindings(
  wrap_GetSamenMetenAPIinfoMuni = function(gemid) {
    municipinfo_amersfoort
  }
)

local_mocked_bindings(
  wrap_GetSamenMetenAPIinfoProject = function(project) {
    projinfo_amersfoort
  }
)


expected_stations <- function(info) {
    sensors <- info$sensor_data |>
        dplyr::pull(kit_id)

    knmi <- info$sensor_data |>
        dplyr::pull(knmicode) |>
        unique()
    knmi <- sub("knmi_06", "KNMI_", knmi)

    ref_station <- info$sensor_data |>
        dplyr::select(dplyr::starts_with("pm")) |>
        tidyr::pivot_longer(
            cols = dplyr::starts_with("pm"),
            names_to = "stat"
        ) |>
        dplyr::pull(value) |>
        unique()

    c(sensors, knmi, ref_station)
}

test_that("get_stations_from_selection() returns project stations", {
    api_get_project_info("Amersfoort", conn = dbconn)

    stations <- get_stations_from_selection(
        name = "Amersfoort",
        type = "project",
        conn = dbconn
    )

    expect_equal(stations, expected_stations(projinfo_amersfoort))
})

test_that("get_stations_from_selection() returns municipality stations", {
    api_get_municipality_info("Amersfoort", conn = dbconn)

    stations <- get_stations_from_selection(
        name = "Amersfoort",
        type = "municipality",
        conn = dbconn
    )

    expect_equal(stations, expected_stations(municipinfo_amersfoort))
})

test_that("get_stations_from_selection() returns NULL for missing selection", {
    stations <- get_stations_from_selection(
        name = "municipality_that_does_not_exist",
        type = "municipality",
        conn = dbconn
    )

    expect_null(stations)
})

test_that("get_stations_from_selection() errors for unknown type", {
    expect_error(
        get_stations_from_selection(
            name = "Amersfoort",
            type = "not_a_known_type",
            conn = dbconn
        ),
        "unknown type"
 )
})
