source("functions/fetch_table_data.R")
source("functions/round_maths.R")
source("functions/gini_coeff.R")

einkommen_table <- function(conn, year) {

  if (is.null(conn) || !DBI::dbIsValid(conn)) stop("❌ Ungültige DB-Verbindung (conn).")
  year <- as.numeric(year)
  if (is.na(year)) stop("❌ year muss numerisch sein.")

  # Erwartung: bootstrap_packages.R lädt tidyverse + openxlsx

  wohnviertel_lut <- tibble(
    Wohnviertel = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 30),
    Wohnviertel_name = c(
      "Altstadt Grossbasel",
      "Vorstädte",
      "Am Ring",
      "Breite",
      "St. Alban",
      "Gundeldingen",
      "Bruderholz",
      "Bachletten",
      "Gotthelf",
      "Iselin",
      "St. Johann",
      "Altstadt Kleinbasel",
      "Clara",
      "Wettstein",
      "Hirzbrunnen",
      "Rosental",
      "Matthäus",
      "Klybeck",
      "Kleinhüningen",
      "Riehen",
      "Bettingen"
    )
  )

  cols <- c(
    "Steuerjahr",
    "Wohnviertel",
    "Reineinkommen",
    "Einkommen_steuerbar",
    "Einkommen_Steuerbetrag_ktgde"
  )

  df <- fetch_table_data(
    conn = conn,
    schema = "sas",
    table_name = "np_zeitreihe_ab_1991_WUA",
    columns = cols
  )
  if (nrow(df) == 0) stop("❌ Keine Daten aus der DB zurückgegeben.")

  df <- df %>%
    mutate(
      Steuerjahr = as.numeric(Steuerjahr),
      Wohnviertel = as.numeric(Wohnviertel),
      Reineinkommen = as.numeric(Reineinkommen),
      Einkommen_steuerbar = as.numeric(Einkommen_steuerbar),
      Einkommen_Steuerbetrag_ktgde = as.numeric(Einkommen_Steuerbetrag_ktgde)
    ) %>%
    filter(Steuerjahr == year)

  if (nrow(df) == 0) stop(sprintf("❌ Keine Daten für Steuerjahr %s gefunden.", year))

  # Code -> Name
  df <- df %>%
    left_join(wohnviertel_lut, by = "Wohnviertel") %>%
    mutate(
      Wohnviertel_name = if_else(is.na(Wohnviertel_name), as.character(Wohnviertel), Wohnviertel_name)
    )

  # --- Wohnviertel-Ebene (nur nach Code gruppieren, Name über first()) ---
  wv <- df %>%
    group_by(Wohnviertel) %>%
    summarise(
      Steuerjahr = year,
      Geo = first(Wohnviertel_name),
      `Anzahl Veranlagungen` = n(),

      `Reineinkommen Summe` = round_maths(sum(Reineinkommen, na.rm = TRUE)),
      `Reineinkommen Mittelwert` = round_maths(mean(Reineinkommen, na.rm = TRUE)),
      `Reineinkommen Median` = round_maths(median(Reineinkommen, na.rm = TRUE)),
      `Reineinkommen Gini` = gini_coeff(Reineinkommen),

      `Einkommen steuerbar Summe` = round_maths(sum(Einkommen_steuerbar, na.rm = TRUE)),
      `Einkommen steuerbar Mittelwert` = round_maths(mean(Einkommen_steuerbar, na.rm = TRUE)),
      `Einkommen steuerbar Median` = round_maths(median(Einkommen_steuerbar, na.rm = TRUE)),
      `Einkommen steuerbar Gini` = gini_coeff(Einkommen_steuerbar),

      `Einkommen Steuerbetrag Summe` = round_maths(sum(Einkommen_Steuerbetrag_ktgde, na.rm = TRUE)),
      `Einkommen Steuerbetrag Mittelwert` = round_maths(mean(Einkommen_Steuerbetrag_ktgde, na.rm = TRUE)),
      `Einkommen Steuerbetrag Median` = round_maths(median(Einkommen_Steuerbetrag_ktgde, na.rm = TRUE)),
      `Einkommen Steuerbetrag Gini` = gini_coeff(Einkommen_Steuerbetrag_ktgde),

      .groups = "drop"
    ) %>%
    arrange(Wohnviertel) %>%
    select(
      Steuerjahr, Geo,
      `Anzahl Veranlagungen`,
      `Reineinkommen Summe`, `Reineinkommen Mittelwert`, `Reineinkommen Median`, `Reineinkommen Gini`,
      `Einkommen steuerbar Summe`, `Einkommen steuerbar Mittelwert`, `Einkommen steuerbar Median`, `Einkommen steuerbar Gini`,
      `Einkommen Steuerbetrag Summe`, `Einkommen Steuerbetrag Mittelwert`, `Einkommen Steuerbetrag Median`, `Einkommen Steuerbetrag Gini`
    )

  # --- Aggregationen ---
  land_mask <- df$Wohnviertel_name %in% c("Riehen", "Bettingen")

  make_agg <- function(label, mask_vec) {
    sub <- df[mask_vec, , drop = FALSE]

    data.frame(
      Steuerjahr = year,
      Geo = label,
      `Anzahl Veranlagungen` = nrow(sub),

      `Reineinkommen Summe` = round_maths(sum(sub$Reineinkommen, na.rm = TRUE)),
      `Reineinkommen Mittelwert` = round_maths(mean(sub$Reineinkommen, na.rm = TRUE)),
      `Reineinkommen Median` = round_maths(median(sub$Reineinkommen, na.rm = TRUE)),
      `Reineinkommen Gini` = gini_coeff(sub$Reineinkommen),

      `Einkommen steuerbar Summe` = round_maths(sum(sub$Einkommen_steuerbar, na.rm = TRUE)),
      `Einkommen steuerbar Mittelwert` = round_maths(mean(sub$Einkommen_steuerbar, na.rm = TRUE)),
      `Einkommen steuerbar Median` = round_maths(median(sub$Einkommen_steuerbar, na.rm = TRUE)),
      `Einkommen steuerbar Gini` = gini_coeff(sub$Einkommen_steuerbar),

      `Einkommen Steuerbetrag Summe` = round_maths(sum(sub$Einkommen_Steuerbetrag_ktgde, na.rm = TRUE)),
      `Einkommen Steuerbetrag Mittelwert` = round_maths(mean(sub$Einkommen_Steuerbetrag_ktgde, na.rm = TRUE)),
      `Einkommen Steuerbetrag Median` = round_maths(median(sub$Einkommen_Steuerbetrag_ktgde, na.rm = TRUE)),
      `Einkommen Steuerbetrag Gini` = gini_coeff(sub$Einkommen_Steuerbetrag_ktgde),

      check.names = FALSE
    )
  }

  bs <- make_agg("BS", rep(TRUE, nrow(df)))
  basel_stadt <- make_agg("Basel-Stadt", !land_mask)  # ohne Riehen & Bettingen
  land <- make_agg("Landgemeinden (d.h. Riehen + Bettingen)", land_mask)

  bind_rows(wv, bs, basel_stadt, land)


}
