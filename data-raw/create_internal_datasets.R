# Create test datasets

#Create sensor dataset


###################################
# project info Amersfoort
projinfo_amersfoort <- samanapir::GetSamenMetenAPIinfoProject("Amersfoort")

###################################
# LML data example
date_range_fixed <- tibble::tibble(
    start_date = as.Date("2025-01-01"),
    end_date = as.Date("2025-01-08")
)

x <- c(date_range_fixed$start_date, date_range_fixed$end_date)
ts_api <- strftime(lubridate::as_datetime(x[1]), format = "%Y%m%d")
te_api <- strftime(lubridate::as_datetime(x[2]), format = "%Y%m%d")
lmlstation <- "NL49680"

lml_example <- samanapir::GetLMLstatdataAPI(lmlstation, ts_api, te_api)

###################################
# Municipality data

# read in municipalities codes and names
municipalities  <- read.csv(here::here("data-raw", "municipalities.csv"),
                             sep = ",", header = TRUE,
                             stringsAsFactors = FALSE)

test_municipality <- "Amersfoort"


gemid <- municipalities %>%
    filter(name == test_municipality) %>%
    pull(code) %>%
    as.character()

municipinfo_amersfoort <- samanapir::GetSamenMetenAPIinfoMuni(gemid)


usethis::use_data(projinfo_amersfoort, lml_example, municipalities,
                  municipinfo_amersfoort, date_range_fixed,
                  overwrite = TRUE, internal = TRUE)

