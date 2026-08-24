library(here)
library(dplyr)
library(readr)

load_stock_window <- function(path = here::here("data", "sp500_stocks.csv"),
                               ticker,
                               start_date,
                               end_date,
                               train_frac = 0.66) {
  raw <- read_csv(path, show_col_types = FALSE)

  window <- raw %>%
    filter(symbol == ticker,
           date >= as.Date(start_date),
           date <= as.Date(end_date)) %>%
    arrange(date)

  n_train <- floor(nrow(window) * train_frac)

  list(
    train = window[seq_len(n_train), ],
    test  = window[seq(n_train + 1, nrow(window)), ]
  )
}
