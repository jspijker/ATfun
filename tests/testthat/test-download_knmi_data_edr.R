
# fixed data, check with raw-data/create_tests_datasets.R

xdate <- c(date_range_fixed$start_date, date_range_fixed$end_date)
ts_api <- strftime(lubridate::as_datetime(xdate[1]), format = "%Y%m%d")
te_api <- strftime(lubridate::as_datetime(xdate[2]), format = "%Y%m%d")
knmistation <- "260"

#Create wrapper around samanapir function - Data
local_mocked_bindings(wrap_GetKNMIAPIEDR = function(station, ts_api, te_api) {
    return(knmi_edr_example)
})

test_that("download_knmi_data_edr() works", {
    x <- download_data_knmi_edr(c("20260501", "20260502"), knmistation)
    expect_true(is.data.frame(x))
    expect_named(object = x, expected = c("station", "value", "timestamp", 
                                          "parameter", "aggregation"),
                 ignore.order = TRUE)
    expect_true(nrow(x) > 0)
})


#Create wrapper around samanapir function - NULL
local_mocked_bindings(wrap_GetKNMIAPIEDR = function(station, ts_api, te_api) {
  return(NULL)
})

test_that("download_knmi_data_edr() returns null", {
  x <- download_data_knmi_edr(c("20260501", "20260502"), knmistation)
  expect_true(is.null(x))
})

#Create wrapper around samanapir function - empty df
local_mocked_bindings(wrap_GetKNMIAPIEDR = function(station, ts_api, te_api) {
  # Return empty dataframe if station returns no data
  knmi_measurements <- data.frame(matrix(ncol = 7, nrow = 0))
  colnames(knmi_measurements) <-
    c("date_time", "id_nr", "parameter_name", "values", "lat", "lon", 
      "result_type")
  return(knmi_measurements)
})

test_that("download_knmi_data_edr() returns empty df", {
  x <- download_data_knmi_edr(c("20260501", "20260502"), knmistation)
  expect_true(is.data.frame(x))
  expect_named(object = x, expected = c("station", "value", "timestamp", 
                                        "parameter", "aggregation"),
               ignore.order = TRUE)
  expect_true(nrow(x) == 0)
})
