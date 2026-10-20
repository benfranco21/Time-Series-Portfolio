# Calendar regressors for the Eskom daily peak (same definitions as Project 3)

hol_dates <- as.Date(c(
  "2022-04-15","2022-04-18","2022-04-27","2022-05-02","2022-06-16","2022-08-09",
  "2022-12-16","2022-12-26","2022-12-27",
  "2023-01-02","2023-03-21","2023-04-07","2023-04-10","2023-04-27","2023-05-01",
  "2023-06-16","2023-08-09","2023-09-25","2023-12-15","2023-12-25","2023-12-26",
  "2024-01-01","2024-03-21","2024-03-29","2024-04-01","2024-05-01","2024-05-29",
  "2024-06-17","2024-08-09","2024-09-24","2024-12-16","2024-12-25","2024-12-26",
  "2025-01-01","2025-03-21","2025-04-18","2025-04-21","2025-04-28","2025-05-01",
  "2025-06-16","2025-09-24","2025-12-16","2025-12-25","2025-12-26",
  "2026-01-01","2026-04-03","2026-04-06","2026-04-27","2026-05-01","2026-06-16",
  "2026-08-10","2026-09-24"))

easter_sun <- as.Date(c("2022-04-17", "2023-04-09", "2024-03-31", "2025-04-20", "2026-04-05"))

add_calendar <- function(df) {
  md <- format(df$date, "%m-%d")
  df$holiday <- df$date %in% hol_dates
  df$easter  <- df$date %in% c(easter_sun - 3, easter_sun - 1, easter_sun)
  df$yearend <- md >= "12-24" | md <= "01-02"
  df
}

reg_data <- function(df, K, t0) {
  tt  <- as.numeric(df$date - t0) + 1
  out <- data.frame(peak = df$peak, t = tt,
                    dow  = factor(wday(df$date, week_start = 1), levels = 1:7,
                                  labels = c("Mon","Tue","Wed","Thu","Fri","Sat","Sun")),
                    holiday = as.numeric(df$holiday),
                    easter  = as.numeric(df$easter),
                    yearend = as.numeric(df$yearend))
  for (k in 1:K) {
    out[[paste0("S", k)]] <- sin(2 * pi * k * tt / 365.25)
    out[[paste0("C", k)]] <- cos(2 * pi * k * tt / 365.25)
  }
  out
}

# regressor matrix for the state space model: no intercept and no trend,
# because the moving level takes over both (Monday is the baseline weekday)
make_xreg_ss <- function(d) {
  model.matrix(peak ~ . - t, data = d)[, -1]
}
