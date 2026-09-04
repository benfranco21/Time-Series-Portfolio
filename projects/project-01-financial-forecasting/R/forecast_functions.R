final_eval_price <- function(price, order, horizons, test_start, test_end){
    out = data.frame()
    for(h in horizons){
        origins <- seq(test_start, test_end - h)
        errors <- numeric(length(origins))
        for (i in seq_along(origins)){
            origin <- origins[i]
            fit <- tryCatch(arima(price[1:origin], order = order), error = function(e) NULL)
            if (is.null(fit)) {errors[i] <- NA; next}
            fc <- tryCatch(predict(fit, n.ahead = h)$pred, error = function(e) rep(NA,h))
            errors[i] <- price[origin + h] - fc[h]
        }
        out <- rbind(out, data.frame(
            Horizon = h,
            RMSE = sqrt(mean(errors^2, na.rm = TRUE)),
            MAE = mean(abs(errors), na.rm = TRUE),
            n_origins = sum(!is.na(errors))
        ))
    }
    out
}

final_eval_returns_as_price <- function(returns, price, order, horizons, test_start, test_end){
    out = data.frame()
    for(h in horizons){
        origins <- seq(test_start, test_end - h)
        errors <- numeric(length(origins))
        for (i in seq_along(origins)){
            origin <- origins[i]
            fit <- tryCatch(arima(returns[1:origin], order = order), error = function(e) NULL)
            if (is.null(fit)) {errors[i] <- NA; next}
            fc <- tryCatch(predict(fit, n.ahead = h)$pred, error = function(e) rep(NA,h))
            implied_price <- price[origin + 1] * exp(sum(fc))
            errors[i] <- price[origin + h + 1] - implied_price
        }
        out <- rbind(out, data.frame(
            Horizon = h,
            RMSE = sqrt(mean(errors^2, na.rm = TRUE)),
            MAE = mean(abs(errors), na.rm = TRUE),
            n_origins = sum(!is.na(errors))
        ))
    }
    out
}