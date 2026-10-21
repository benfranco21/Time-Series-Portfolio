kalman_filter <- function(y, FF, GG, W, V, m0, c0, skip = 0) {
    n <- length(y)
    p <- length(m0)
    a <- m <- matrix(NA, n,p)
    R <- C <- array(NA, c(p,p,n))
    f <- Q <- e <- rep(NA,n)
    mt <- m0 
    ct <- c0

    for(t in 1:n){
        # 1. predict the state
        at <- GG %*% mt
        Rt <- GG %*% ct %*% t(GG) + W

        # 2. predict the obs
        Ft <- matrix(FF[t,], nrow = 1)
        ft <- as.numeric(Ft %*% at)
        Qt <- as.numeric(Ft %*% Rt %*% t(Ft)) + V

        # 3. update param
        if (is.na(y[t])){
            et <- NA
            mt <- at
            ct <- Rt
        } else {
            et <- y[t] - ft
            Kt <- Rt %*% t(Ft) / Qt
            mt <- at + Kt * et
            ct <- Rt - Kt %*% Ft %*% Rt
        }
        a[t,] <- at
        R[, , t] <- Rt
        f[t] <- ft
        Q[t] <- Qt
        e[t] <- et
        m[t,] <- mt
        C[,,t] <- ct
        
    }

    ok <- !is.na(e)
    ok[seq_len(skip)] <- FALSE
    loglik <- -0.5 * sum(log(Q[ok]) + e[ok]^2 / Q[ok])
    list(a = a, R= R, f=f, Q = Q, e= e, m = m, C= C, loglik = loglik)
}


kalman_smoother <- function(kf, GG){
    n <- nrow(kf$m)
    s <- kf$m
    S <- kf$C
    for (i in (n-1):1){
        Bt <- kf$C[,,i] %*% t(GG) %*% solve(kf$R[,,i+1])
        s[i,] <- kf$m[i,] + Bt %*% (s[i + 1,] - kf$a[i+1,])
        S[,,i] <- kf$C[,,i] - Bt %*% (kf$R[,,i+1] - S[,,i+1]) %*% t(Bt)

    }
    list(s = s, S = S)
}