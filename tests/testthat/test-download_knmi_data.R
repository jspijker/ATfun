
# fixed data, check with raw-data/create_tests_datasets.R

xdate <- c(date_range_fixed$start_date, date_range_fixed$end_date)

#Create wrapper around samanapir function
local_mocked_bindings(wrap_GetKNMIAPI = function(station, ts_api, te_api) {
    return(knmi_example)
})

test_that("download_knmi_data() works", {
    x <- download_data_knmi(xdate, knmistation)
    expect_true(is.data.frame(x))
    expect_named(object = x, expected = c("station", "value", "timestamp", 
                                          "parameter", "aggregation"),
                 ignore.order = TRUE)
    expect_true(nrow(x) > 0)
})


#Create wrapper around samanapir function - NULL
local_mocked_bindings(wrap_GetKNMIAPI = function(station, ts_api, te_api) {
  return(NULL)
})

test_that("download_knmi_data() returns null", {
  x <- download_data_knmi(c("20260501", "20260502"), knmistation)
  expect_true(is.null(x))
})
