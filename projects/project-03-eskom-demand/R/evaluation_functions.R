# Rolling-origin forecasts, RMSE/MAE/MAPE/CRPS and interval coverage
rmse <- function(actual, predicted) {
    sqrt(mean((actual - predicted)^2, na.rm = TRUE))
}

mae <- function(actual, predicted){
    mean(abs(actual - predicted), na.rm = TRUE)
}

mape <- function(actual, predicted){
   100 *  mean(abs((actual - predicted)/actual), na.rm = TRUE)
}

point_metrics <- function(actual, fc) {
  c(RMSE = rmse(actual, fc), MAE = mae(actual, fc), MAPE = mape(actual, fc))
}

coverage <- function(actual, lower, upper) {
  mean(actual >= lower & actual <= upper, na.rm = TRUE)
}

crps_norm <- function(actual, mu, sigma) {
  z <- (actual - mu) / sigma
  mean(sigma * (z * (2 * pnorm(z) - 1) + 2 * dnorm(z) - 1 / sqrt(pi)), na.rm = TRUE)
}
