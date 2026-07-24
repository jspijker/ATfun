
# make sure we start with a clean database
try(pool::poolClose(dbconn))
reset_db(fname_db)
dbconn <- pool::dbPool(drv = RSQLite::SQLite(),
                       dbname = fname_db)



local_mocked_bindings(wrap_GetSamenMetenAPIinfoMuni = function(gemid) {
    logger::log_info("mocked GetSamenMetenAPIinfoMuni called")
    return(municipinfo_amersfoort)
})


local_mocked_bindings(wrap_GetSamenMetenAPIinfoProject = function(project) {
    logger::log_info("mocked GetSamenMetenAPIinfoProject called")
    return(projinfo_amersfoort)
})

test_that("download_sensor_meta project", {

    # 'Download' Amersfoort project metadata and store in
    # database, a mocking function is used to return the
    # Amersfoort project metadata instead of downloading it
    # from the SamenMeten API.
    download_sensor_meta("Amersfoort", type = "project", dbconn)


    #check if the expected types are present in the database
    res <- list_doc_types(conn = dbconn)
    types_present <- c("project", "datastream", "station")
    testthat::expect_true(all(types_present %in% res))

    # check if the number of stations and datastreams are
    # correct

    res <- list_doc_all(conn = dbconn)
    nstation_info <- projinfo_amersfoort$sensor_data |>
        dplyr::select(kit_id) |>
        dplyr::distinct() |>
        nrow()

    nstation_meta <- res |>
        dplyr::filter(type == "station") |>
        nrow()

    ndatastream_meta <- res |>
        dplyr::filter(type == "datastream") |>
        nrow()

    testthat::expect_equal(nstation_info, nstation_meta)
    testthat::expect_equal(nstation_meta, ndatastream_meta)
})



# make sure we start with a clean database
try(pool::poolClose(dbconn))
reset_db(fname_db)
dbconn <- pool::dbPool(drv = RSQLite::SQLite(),
                       dbname = fname_db)

test_that("download_sensor_meta municipality", {

    # 'Download' Amersfoort project metadata and store in
    # database, a mocking function is used to return the
    # Amersfoort project metadata instead of downloading it
    # from the SamenMeten API.
    download_sensor_meta("Amersfoort", type = "municipality", dbconn)


    #check if the expected types are present in the database
    res <- list_doc_types(conn = dbconn)
    types_present <- c("municipality", "datastream", "station")
    testthat::expect_true(all(types_present %in% res))

    # check if the number of stations and datastreams are
    # correct

    res <- list_doc_all(conn = dbconn)
    nstation_info <- municipinfo_amersfoort$sensor_data |>
        dplyr::select(kit_id) |>
        dplyr::distinct() |>
        nrow()

    nstation_meta <- res |>
        dplyr::filter(type == "station") |>
        nrow()

    ndatastream_meta <- res |>
        dplyr::filter(type == "datastream") |>
        nrow()

    testthat::expect_equal(nstation_info, nstation_meta)
    testthat::expect_equal(nstation_meta, ndatastream_meta)
})

