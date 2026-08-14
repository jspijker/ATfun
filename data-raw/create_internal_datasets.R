# Create test datasets

#Create sensor dataset ----
remotes::install_github('rivm-syso/samanapir', ref = 'add_httr2_incl_tests', force = TRUE)
remotes::install_github('rivm-syso/ATdatabase')

library(samanapir)
library(ATdatabase) # shouldn't be loaded, see issue 23 ATdatabase

###################################
# project info Amersfoort ----
projinfo_amersfoort <- samanapir::GetSamenMetenAPIinfoProject2("Amersfoort")

###################################
# LML data example ----
date_range_fixed <- tibble::tibble(
    start_date = as.Date("2026-01-01"),
    end_date = as.Date("2026-01-08")
)

x <- c(date_range_fixed$start_date, date_range_fixed$end_date)
ts_api <- strftime(lubridate::as_datetime(x[1]), format = "%Y%m%d")
te_api <- strftime(lubridate::as_datetime(x[2]), format = "%Y%m%d")
lmlstation <- "NL49680"

lml_example <- samanapir::GetLMLstatdataAPI2(lmlstation, ts_api, te_api)

###################################
# KNMI data ---- 
date_range_fixed <- tibble::tibble(
  start_date = as.Date("2026-01-01"),
  end_date = as.Date("2026-01-08")
)
x <- c(date_range_fixed$start_date, date_range_fixed$end_date)
ts_api <- strftime(lubridate::as_datetime(x[1]), format = "%Y%m%d")
te_api <- strftime(lubridate::as_datetime(x[2]), format = "%Y%m%d")
knmistation <- "260"

knmi_example <- samanapir::GetKNMIAPI2(knmistation, ts_api, te_api)

###################################
# KNMI data EDR ----
date_range_fixed <- tibble::tibble(
  start_date = as.Date("2026-01-01"),
  end_date = as.Date("2026-01-08")
)
x <- c(date_range_fixed$start_date, date_range_fixed$end_date)
ts_api <- strftime(lubridate::as_datetime(x[1]), format = "%Y%m%d")
te_api <- strftime(lubridate::as_datetime(x[2]), format = "%Y%m%d")
knmistation <- "260"

# Set token for knmi api
Sys.setenv(KNMI_API_TOKEN = ""
)


knmi_edr_example <- samanapir::GetKNMIAPIEDR(date_start = ts_api,
                                             date_end = te_api, 
                                             token = Sys.getenv("KNMI_API_TOKEN"),
                                             location_id = knmistation, 
                                             parameter = "wind",
                                             data_result = "hourly")


###################################
# Municipality data ----

# read in municipalities codes and names
municipalities  <- read.csv(here::here("data-raw", "municipalities.csv"),
                             sep = ",", header = TRUE,
                             stringsAsFactors = FALSE)

test_municipality <- "Amersfoort"


gemid <- municipalities  |> 
    dplyr::filter(name == test_municipality)  |> 
    dplyr::pull(code)  |> 
    as.character()

municipinfo_amersfoort <- samanapir::GetSamenMetenAPIinfoMuni2(gemid)






sm_station <- "SMC_16554"
sm_streams  <- c(52429, 52428, 52427, 52426)

obs <- list()
for(i in sm_streams) {
    id <- paste0("X", i)
    obs[[id]] <- samanapir::GetSamenMetenAPIobs2(as.character(i), sm_station, ts_api, te_api)
}
samenmeten_example  <- obs
#add attribute streams to samenmeten_example
attr(samenmeten_example, "streams") <- sm_streams
attr(samenmeten_example, "station") <- sm_station
attr(samenmeten_example, "datarange") <- date_range_fixed

# save ----
usethis::use_data(projinfo_amersfoort, lml_example, municipalities,
                  municipinfo_amersfoort, date_range_fixed,
                  samenmeten_example, knmi_example, knmi_edr_example,
                  overwrite = TRUE, internal = TRUE)

