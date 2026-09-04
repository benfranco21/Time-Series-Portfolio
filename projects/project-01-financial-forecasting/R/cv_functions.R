rolling_cv <- function(x, order, horizons, initial, step){
    n <- length(x)
    Q <- mean(abs(diff(x)))
    out <- data.frame()
    for (h in horizons){
        origins <- seq(initial, n - h, by = step)
        errors <- numeric(length(origins))
        for (i in seq_along(origins)){
            origin <- origins[i]
            train_sub <- x[1:origin]
            fit <- tryCatch(arima(train_sub, order = order), error = function(e) NULL)
            if (is.null(fit)) {errors[i] <- NA; next}
            fc <- tryCatch(predict(fit, n.ahead = h)$pred, error = function(e) rep(NA,h))
            errors[i] <- x[origin + h] - fc[h]
        }

        out <- rbind(out, data.frame(
            Horizon = h,
            RMSE = sqrt(mean(errors^2, na.rm = TRUE)),
            MAE = mean(abs(errors), na.rm = TRUE),
            MASE = mean(abs(errors), na.rm = TRUE)/Q,
            n_origins = sum(!is.na(errors))
        ))
    }
    out

}
