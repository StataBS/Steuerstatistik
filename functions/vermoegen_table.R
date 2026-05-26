source("functions/fetch_table_data.R")
source("functions/round_maths.R")
source("functions/gini_coeff.R")

vermoegen_table <- function(conn, year) {
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
    "Reinvermögen",
    "Vermögen_steuerbar",
    "Vermögen_Steuerbetrag_ktgde"
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
      Reinvermögen = as.numeric(Reinvermögen),
      Vermögen_steuerbar = as.numeric(Vermögen_steuerbar),
      Vermögen_Steuerbetrag_ktgde = as.numeric(Vermögen_Steuerbetrag_ktgde)
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
      `Reinvermögen Summe` = round_maths(sum(Reinvermögen, na.rm = TRUE)),
      `Reinvermögen Mittelwert` = round_maths(mean(Reinvermögen, na.rm = TRUE)),
      `Reinvermögen Median` = round_maths(median(Reinvermögen, na.rm = TRUE)),
      `Reinvermögen Gini` = gini_coeff(Reinvermögen),
      
      `Vermögen steuerbar Summe` = round_maths(sum(Vermögen_steuerbar, na.rm = TRUE)),
      `Vermögen steuerbar Mittelwert` = round_maths(mean(Vermögen_steuerbar, na.rm = TRUE)),
      `Vermögen steuerbar Median` = round_maths(median(Vermögen_steuerbar, na.rm = TRUE)),
      `Vermögen steuerbar Gini` = gini_coeff(Vermögen_steuerbar),
      
      `Vermögen Steuerbetrag Summe` = round_maths(sum(Vermögen_Steuerbetrag_ktgde, na.rm = TRUE)),
      `Vermögen Steuerbetrag Mittelwert` = round_maths(mean(Vermögen_Steuerbetrag_ktgde, na.rm = TRUE)),
      `Vermögen Steuerbetrag Median` = round_maths(median(Vermögen_Steuerbetrag_ktgde, na.rm = TRUE)),
      `Vermögen Steuerbetrag Gini` = gini_coeff(Vermögen_Steuerbetrag_ktgde),
      
      .groups = "drop"
    ) %>%
    arrange(Wohnviertel) %>%
    select(
      Steuerjahr, Geo,
      `Anzahl Veranlagungen`,
      `Reinvermögen Summe`, `Reinvermögen Mittelwert`, `Reinvermögen Median`, `Reinvermögen Gini`,
      `Vermögen steuerbar Summe`, `Vermögen steuerbar Mittelwert`, `Vermögen steuerbar Median`, `Vermögen steuerbar Gini`,
      `Vermögen Steuerbetrag Summe`, `Vermögen Steuerbetrag Mittelwert`, `Vermögen Steuerbetrag Median`, `Vermögen Steuerbetrag Gini`
    )

  # --- Aggregationen ---
  land_mask <- df$Wohnviertel_name %in% c("Riehen", "Bettingen")

  make_agg <- function(label, mask_vec) {
    sub <- df[mask_vec, , drop = FALSE]

    data.frame(
      Steuerjahr = year,
      Geo = label,
      `Anzahl Veranlagungen` = nrow(sub),
      `Reinvermögen Summe` = round_maths(sum(sub$Reinvermögen, na.rm = TRUE)),
      `Reinvermögen Mittelwert` = round_maths(mean(sub$Reinvermögen, na.rm = TRUE)),
      `Reinvermögen Median` = round_maths(median(sub$Reinvermögen, na.rm = TRUE)),
      `Reinvermögen Gini` = gini_coeff(sub$Reinvermögen),
      
      `Vermögen steuerbar Summe` = round_maths(sum(sub$Vermögen_steuerbar, na.rm = TRUE)),
      `Vermögen steuerbar Mittelwert` = round_maths(mean(sub$Vermögen_steuerbar, na.rm = TRUE)),
      `Vermögen steuerbar Median` = round_maths(median(sub$Vermögen_steuerbar, na.rm = TRUE)),
      `Vermögen steuerbar Gini` = gini_coeff(sub$Vermögen_steuerbar),
      
      `Vermögen Steuerbetrag Summe` = round_maths(sum(sub$Vermögen_Steuerbetrag_ktgde, na.rm = TRUE)),
      `Vermögen Steuerbetrag Mittelwert` = round_maths(mean(sub$Vermögen_Steuerbetrag_ktgde, na.rm = TRUE)),
      `Vermögen Steuerbetrag Median` = round_maths(median(sub$Vermögen_Steuerbetrag_ktgde, na.rm = TRUE)),
      `Vermögen Steuerbetrag Gini` = gini_coeff(sub$Vermögen_Steuerbetrag_ktgde),
      
      check.names = FALSE
    )
  }

  bs <- make_agg("BS", rep(TRUE, nrow(df)))
  basel_stadt <- make_agg("Basel-Stadt", !land_mask) # ohne Riehen & Bettingen
  land <- make_agg("Landgemeinden (d.h. Riehen + Bettingen)", land_mask)

  bind_rows(wv, bs, basel_stadt, land)
}
