
#Create wrapper around samanapir function
wrap_GetSamenMetenAPIinfoProject <- function(project) {
    return(projinfo_amersfoort)
}


test_that("download_lml_data wrapper", {
    x <- api_get_project_info("Amersfoort", conn = dbconn)
    expect_true(is.list(x))
    expect_true(length(x) == 2)
    expect_named(x, c("sensor_data", "datastream_data"))

    doc <- ATdatabase::get_doc(type = "project", ref = "Amersfoort", conn = dbconn)
    expect_true(is.list(doc)) |>
    expect_true(length(doc) == 2) |>
    expect_named(object = doc, expected = c("sensor_data", "datastream_data"))


})
