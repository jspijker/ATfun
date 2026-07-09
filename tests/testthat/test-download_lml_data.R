
# fixed data, check with raw-data/create_tests_datasets.R

#Create wrapper around samanapir function
wrap_GetLMLstatdataAPI <- function(project) {
    return(lml_example)
}



test_that("download_lml_data() works", {
              x <- download_data_lml(lmlstation, date_range_fixed)
              expect_true(is.data.frame(x))
              expect_named(object = x, expected = c("station", "value", "timestamp", "parameter", "aggregation"))
              expect_true(nrow(x) > 0)
})


