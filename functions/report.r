report <- function(blocks, tolerance_pct = NULL) {

  for (nm in names(blocks)) {

    title <- blocks[[nm]]$title
    dat   <- blocks[[nm]]$data

    if (is.null(dat) || nrow(dat) == 0) {
      cat(title, "\n")
      cat("  Keine Daten.\n\n")
      next
    }

    value_cols <- setdiff(colnames(dat), "Geo")
    if (length(value_cols) == 0) {
      cat(title, "\n")
      cat("  Keine Kennzahlspalten.\n\n")
      next
    }

    long <- dat %>%
      tidyr::pivot_longer(
        cols = all_of(value_cols),
        names_to = "Variable",
        values_to = "Value"
      ) %>%
      mutate(Value = as.numeric(Value)) %>%
      filter(!is.na(Value))

    if (nrow(long) == 0) {
      cat(title, "\n")
      cat("  Alle Werte sind NA.\n\n")
      next
    }

    long <- long %>% mutate(AbsValue = abs(Value))
    max_row <- long %>% arrange(desc(AbsValue)) %>% slice(1)

    cat(title, "\n")
    cat(
      "  Grösster Unterschied: ",
      sprintf("%.4f", max_row$Value),
      "% (Geo: ", max_row$Geo, ", Spalte: ", max_row$Variable, ")\n",
      sep = ""
    )

    if (!is.null(tolerance_pct)) {
      n_over <- sum(long$AbsValue > tolerance_pct)
      cat("  Anzahl Werte über Toleranz (|%| > ", tolerance_pct, "): ", n_over, "\n", sep = "")
    }

    cat("\n")
  }
}