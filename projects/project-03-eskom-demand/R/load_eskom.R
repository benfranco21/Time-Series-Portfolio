# Read ESK19847.csv by column position, aggregate hourly RSA Contracted Demand to daily peak, save .rds

library(dplyr)

raw <- read.csv(here::here("data", "ESK19847.csv"), header = FALSE, skip = 1, fill = TRUE, col.names = paste0("V", 1:14))[,1:12]

names(raw) <- c("datetime", "res_fc", "rsa_fc", "res_dem", "rsa_dem",
                "ils", "mlr", "wind", "total_re", "pclf", "uclf", "oclf")

raw$datetime <- as.POSIXct(raw$datetime, format = "%Y-%m-%d %I:%M:%S %p", tz = "UTC")

daily <- raw |>
  filter(!is.na(rsa_dem)) |>
  mutate(date = as.Date(datetime)) |>
  group_by(date) |>
  summarise(n_hours   = n(),
            peak      = max(rsa_dem),                                  
            peak_hour = lubridate::hour(datetime[which.max(rsa_dem)]), 
            eskom_fc  = max(rsa_fc),                                   
            mlr_max   = max(mlr),                                     
            .groups   = "drop")

stopifnot(all(daily$n_hours == 24), !anyDuplicated(daily$date))
saveRDS(daily, here::here("data", "eskom_daily_peak.rds"))



