gini_coeff <- function(x) {
    x <- x[!is.na(x)]
    n <- length(x)

    if (n == 0) {
        return(NA_real_)
    }
    if (n == 1) {
        return(0)
    }

    x <- sort(x)
    mu <- mean(x)
    if (mu == 0) {
        return(0)
    }

    i <- seq_len(n)
    gini <- (2 * sum(i * x)) / (n * sum(x)) - (n + 1) / n

    # 🔹 Rundung auf 5 Nachkommastellen
    round(gini, 5)
}
