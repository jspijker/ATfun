# fixed data, check with raw-data/create_tests_datasets.R

xdate <- c(date_range_fixed$start_date, date_range_fixed$end_date)

#Create wrapper around samanapir function
local_mocked_bindings(wrap_GetKNMIAPIEDR = function(station, ts_api, te_api) {
  return(knmi_edr_example)
})

test_that("download_location_knmi_edr() works", {
  x <- download_location_knmi_edr(knmistation, xdate[1], xdate[2])
  expect_true(is.data.frame(x))
  expect_named(object = x, expected = c("station", "lat", "lon"),
               ignore.order = TRUE)
  expect_equal(x$station, "KNMI_260")
  expect_equal(round(x$lat,1), 52.1)
  expect_equal(round(x$lon,2), 5.18)
  
})

#Create wrapper around samanapir function - NULL
local_mocked_bindings(wrap_GetKNMIAPIEDR = function(station, ts_api, te_api) {
  return(NULL)
})

test_that("download_location_knmi_edr() returns null", {
  x <- download_location_knmi_edr(knmistation, xdate[1], xdate[2])
  expect_true(is.null(x))
})
