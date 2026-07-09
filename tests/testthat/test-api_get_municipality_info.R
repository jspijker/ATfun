

local_mocked_bindings(wrap_GetSamenMetenAPIinfoMuni = function(gemid) {
    return(municipcinfo_amersfoort)
})



test_that("api_get_municipality_info() works", {


    x <- api_get_municipality_info("Amersfoort", conn = dbconn)
    expect_true(is.list(x))
    expect_true(length(x) == 2)
    expect_named(x, c("sensor_data", "datastream_data"))

    doc <- ATdatabase::get_doc(type = "municipality", ref = "Amersfoort", conn = dbconn)
    expect_true(is.list(doc)) |>
    expect_true(length(doc) == 2) |>
    expect_named(object = doc, expected = c("sensor_data", "datastream_data"))

              NULL
})
