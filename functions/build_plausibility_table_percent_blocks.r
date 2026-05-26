build_plausibility_table_percent_blocks <- function(conn, years, table_fun) {

  years <- as.numeric(years)
  years <- years[!is.na(years)]
  years <- sort(unique(years))

  if (length(years) < 2) stop("❌ Mindestens 2 Jahre angeben.")

  tabs <- lapply(years, function(y) table_fun(conn, y))
  names(tabs) <- as.character(years)

  # Gini-Spalten entfernen (falls vorhanden)
  tabs <- lapply(tabs, function(t) {
    gini_cols <- grep("Gini", colnames(t), value = TRUE)
    if (length(gini_cols) > 0) t <- t %>% select(-all_of(gini_cols))
    t
  })

  ref_cols <- colnames(tabs[[1]])
  if (!all(c("Steuerjahr", "Geo") %in% ref_cols)) stop("❌ Erwartete Spalten 'Steuerjahr' und 'Geo' fehlen.")

  value_cols <- setdiff(ref_cols, c("Steuerjahr", "Geo"))

  blocks <- list()

  for (i in 2:length(years)) {

    y1 <- years[i - 1]
    y2 <- years[i]

    t1 <- tabs[[as.character(y1)]] %>% select(Geo, all_of(value_cols))
    t2 <- tabs[[as.character(y2)]] %>% select(Geo, all_of(value_cols))

    j <- full_join(
      t1 %>% rename_with(~ paste0(.x, "__y1"), all_of(value_cols)),
      t2 %>% rename_with(~ paste0(.x, "__y2"), all_of(value_cols)),
      by = "Geo"
    )

    out <- j

    for (col in value_cols) {
      c1 <- paste0(col, "__y1")
      c2 <- paste0(col, "__y2")

      out[[c1]] <- as.numeric(out[[c1]])
      out[[c2]] <- as.numeric(out[[c2]])

      denom <- out[[c1]]
      pct_name <- paste0(col, " (%)")

      out[[pct_name]] <- ifelse(
        is.na(denom) | denom == 0,
        NA_real_,
        (out[[c2]] - out[[c1]]) / denom * 100
      )
    }

    out <- out %>%
      select(
        Geo,
        all_of(paste0(value_cols, " (%)"))
      )

    blocks[[paste0(y1, "_", y2)]] <- list(
      title = paste0("Vergleich (Prozent): ", y1, "-", y2),
      data = out
    )
  }

  blocks
}
