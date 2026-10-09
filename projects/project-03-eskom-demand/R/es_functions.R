# Hand-coded simple exponential smoothing: updating equations, SSE, optim() estimation, forecasts and intervals
ses_filter <- function(y, alpha, l0){
    n <- length(y)
    level <- numeric(n + 1)
    fitted <- numeric(n)
    error <- numeric(n)
    level[1] <- l0
    for (i in 1:n){
        fitted[i] <- level[i]
        error[i] <- y[i] - fitted[i]
        level[i + 1] <- level[i] + alpha * error[i]
    }
    list(fitted = fitted, error = error, level = level)
}

ses_sse <- function(par, y, l0){
    alpha <- 1/(1 + exp(-par))  # logistic transformation to constrain alpha to (0, 1)
    sum(ses_filter(y, alpha, l0)$error^2)
}