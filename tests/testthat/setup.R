######################################################################
# Test setup 
#
# This file contains default values and helper function. For functions
# that make use of API calls, the API calls are mocked to return fixed
# data stored in this package.
#
#######################################################################




# defailt values
###################################################################

# select randow date range, a week long period in the past
date_range <- tibble::tibble(
    start_date = sample(seq(as.Date("2020-01-01"),
                            as.Date("2025-12-31"), by = "day"), 1),
    end_date = start_date + lubridate::days(7)
)

# Set default project
project <- "Amersfoort"

# set default LML station
lmlstation <- "NL49680"

# set default municipality
municipality <- "Amersfoort"

# create database
###################################################
fname_db <- tempfile(fileext = ".sqlite")
print(fname_db)
reset_db <- reset_db(fname_db)

dbconn <- pool::dbPool(drv = RSQLite::SQLite(),
                       dbname = fname_db)

