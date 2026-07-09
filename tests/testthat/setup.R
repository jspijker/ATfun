



# setup database
fname_db <- tempfile(fileext = ".sqlite")

# remove db if it exists
if (file.exists(fname_db)) {
    file.remove(fname_db)
}

dbconn <- pool::dbPool(drv = RSQLite::SQLite(),
                     dbname = fname_db)

ATdatabase::create_database_tables(dbconn)

# select randow date range, a week long period in the past
date_range <- tibble::tibble(
    start_date = sample(seq(as.Date("2020-01-01"),
                            as.Date("2025-12-31"), by = "day"), 1),
    end_date = start_date + lubridate::days(7)
)

date_range_fixed <- tibble::tibble(
    start_date = as.Date("2024-01-01"),
    end_date = as.Date("2024-01-08")
)

# Set default project
project <- "Amersfoort"

# set default LML station
lmlstation <- "NL49680"




