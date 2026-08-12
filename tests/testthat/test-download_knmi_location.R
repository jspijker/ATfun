# fixed data, check with raw-data/create_tests_datasets.R

xdate <- c(date_range_fixed$start_date, date_range_fixed$end_date)

#Create wrapper around samanapir function
local_mocked_bindings(wrap_GetKNMIAPI = function(station, ts_api, te_api) {
  return(knmi_example)
})

test_that("download_locations_knmi() works", {
  x <- download_location_knmi(knmistation, xdate[1], xdate[2])
  expect_true(is.data.frame(x))
  expect_named(object = x, expected = c("station", "lat", "lon"),
               ignore.order = TRUE)
  expect_equal(x$station, "KNMI_260")
  expect_equal(x$lat, 52.1)
  expect_equal(x$lon, 5.18)
  
})

#Create wrapper around samanapir function - NULL
local_mocked_bindings(wrap_GetKNMIAPI = function(station, ts_api, te_api) {
  return(NULL)
})

test_that("download_locations_knmi() returns null", {
  x <- download_location_knmi(knmistation, xdate[1], xdate[2])
  expect_true(is.null(x))
})
