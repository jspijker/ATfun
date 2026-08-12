# prep test
ts_api  <- strftime(date_range$start_date, format="%Y%m%d")
te_api  <- strftime(date_range$end_date, format="%Y%m%d")

ts <- as.numeric(ts_api)
te <- as.numeric(te_api)
req_matrix <- matrix(c(ts, te), ncol = 2)

station <- "SMC_16554"

pool::poolClose(dbconn)
reset_db(fname_db)
dbconn <- pool::dbPool(drv = RSQLite::SQLite(),
                       dbname = fname_db)


local_mocked_bindings(wrap_GetSamenMetenAPIinfoMuni = function(gemid) {
    logger::log_info("mocked GetSamenMetenAPIinfoMuni called")
    return(municipinfo_amersfoort)
})


test_that("download_data_samenmeten,data returned", {

    local_mocked_bindings(wrap_GetSamenMetenAPIobs = function(stream_id, station, 
                                                              ts_api, te_api) {
        logger::log_info("mocked GetSamenMetenAPIobs called")
        item <- paste0("X", stream_id)
        return(samenmeten_example[[item]])
    })


    download_sensor_meta("Amersfoort", type = "municipality", conn = dbconn)
    x <- download_data_samenmeten(req_matrix, station, conn = dbconn)

    expect_true(is.data.frame(x))
    expect_true(nrow(x) > 0)
    expect_named(x, c("station", "parameter", "timestamp", "value", "aggregation"),
                 ignore.order = TRUE)
})


test_that("download_data_samenmeten,NULL returned", {

    local_mocked_bindings(wrap_GetSamenMetenAPIobs = function(stream_id, station, ts_api, te_api) {
        logger::log_info("mocked GetSamenMetenAPIobs called, NULL returned")
        return(NULL)
    })


    download_sensor_meta("Amersfoort", type = "municipality", conn = dbconn)
    x <- download_data_samenmeten(req_matrix, station, conn = dbconn)
    expect_null(x)
})


test_that("download_data_samenmeten,error returned", {

    local_mocked_bindings(wrap_GetSamenMetenAPIobs = function(stream_id, station, ts_api, te_api) {
        logger::log_info("mocked GetSamenMetenAPIobs called, error returned")
        stop("error")
        return(NULL)
    })


    download_sensor_meta("Amersfoort", type = "municipality", conn = dbconn)
    x <- download_data_samenmeten(req_matrix, station, conn = dbconn)
    expect_null(x)
})




test_that("download_data_samenmeten, empty df returned", {

    local_mocked_bindings(wrap_GetSamenMetenAPIobs = function(stream_id, station, ts_api, te_api) {
        logger::log_info("mocked GetSamenMetenAPIobs called, empy df returned")
        return(data.frame())
    })


    download_sensor_meta("Amersfoort", type = "municipality", conn = dbconn)
    x <- download_data_samenmeten(req_matrix, station, conn = dbconn)
    
    expect_false(is.null(x))
    expect_true(is.data.frame(x))
    expect_true(nrow(x) == 0)
})


#####################
# from here mutations on the database take place

test_that("download_data_samenmeten, use download data, data returned", {

    local_mocked_bindings(wrap_GetSamenMetenAPIobs = function(stream_id, station, ts_api, te_api) {
        logger::log_info("mocked GetSamenMetenAPIobs called")
        item <- paste0("X", stream_id)
        return(samenmeten_example[[item]])
    })



    cache  <-  dplyr::tbl(dbconn, "cache") |>
        dplyr::collect()
    expect_true(nrow(cache) == 0)


    download_data(station, Tstart = as_datetime(date_range$start_date),
                  Tend = as_datetime(date_range$end_date),
                  fun = "download_data_samenmeten",
                  conn = dbconn)

    cache  <-  dplyr::tbl(dbconn, "cache") |>
        dplyr::collect()
    expect_true(nrow(cache) == 1)


})


test_that("download_data_samenmeten, use download data, error returned", {

    local_mocked_bindings(wrap_GetSamenMetenAPIobs = function(stream_id, station, ts_api, te_api) {
        logger::log_info("mocked GetSamenMetenAPIobs called error returned")
        stop("error")
    })

    cache  <-  dplyr::tbl(dbconn, "cache") |>
        dplyr::collect()
    expect_true(nrow(cache) == 1) # 1 from previous test


    download_data(station, Tstart = as_datetime(date_range$start_date),
                  Tend = as_datetime(date_range$end_date),
                  fun = "download_data_samenmeten",
                  conn = dbconn)

    cache  <-  dplyr::tbl(dbconn, "cache") |>
        dplyr::collect()
    expect_true(nrow(cache) == 1)


})


test_that("download_data_samenmeten, use download data, empty data returned", {

    local_mocked_bindings(wrap_GetSamenMetenAPIobs = function(stream_id, station, ts_api, te_api) {
        logger::log_info("mocked GetSamenMetenAPIobs called empty data returned")
        return(data.frame(station = NULL, parameter = NULL,
                          timestamp = NULL, value = NULL,
                          aggregation = NULL)) #zero row df
    })

    cache  <-  dplyr::tbl(dbconn, "cache") |>
        dplyr::collect()
    expect_equal(nrow(cache), 1) # 1 from previous test

    # other time range, so we get a new entry in the cache table
    time_start <- as_datetime(date_range$start_date) - lubridate::days(14)
    time_end <- as_datetime(date_range$end_date) - lubridate::days(14)

    download_data(station, Tstart = time_start,
                  Tend = time_end,
                  fun = "download_data_samenmeten",
                  conn = dbconn)

    cache  <-  dplyr::tbl(dbconn, "cache") |>
        dplyr::collect()
    expect_equal(nrow(cache), 2)


})

