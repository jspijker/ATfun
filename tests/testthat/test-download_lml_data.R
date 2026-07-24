
# fixed data, check with raw-data/create_tests_datasets.R

xdate <- c(date_range_fixed$start_date, date_range_fixed$end_date)

#Create wrapper around samanapir function
local_mocked_bindings(wrap_GetLMLstatdataAPI = function(station, ts_api, te_api) {
    return(lml_example)
})

test_that("download_lml_data() works", {
    x <- download_data_lml(xdate, lmlstation)
    expect_true(is.data.frame(x))
    expect_named(object = x, expected = c("station", "value", "timestamp", "parameter", "timestamp_measured_start",
                                          "timestamp_measured_end",  "aggregation"))
    expect_true(nrow(x) > 0)
})

