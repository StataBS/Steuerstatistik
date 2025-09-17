# The function id_6912 calculates the total withholding tax and number of tax
# cases grouped by income category (Bezugskategorie) for the selected year and
# 9 years before.
#
# @param conn A database connection object
# @param year The reference tax year (e.g. 2022).

source("functions/fetch_table_data.R")
source("functions/round_maths.R")

id_6912 <- function(conn, year) {
  # Define columns
  columns <- c(
    "steuerjahr",
    "steuer_netto",
    "Bezugskategorie"
  )

  # Fetch data
  df <- fetch_table_data(
    conn = conn,
    view = "sasqst",
    table_name = "quellensteuer_zeitreihe",
    columns = columns
  )

  # Check if DataFrame is empty
  if (nrow(df) == 0) {
    stop("Error: The DataFrame is empty!")
  }

  # Filter out "Keine Angabe"
  df <- df[df$Bezugskategorie != "Keine Angabe", ]

  # Convert steuer_netto to numeric
  df$steuer_netto <- as.numeric(df$steuer_netto)

  # Define years
  year_start <- year - 9
  year_end <- year

  # Berechnung für year_start
  df_start <- df[df$steuerjahr == year_start, ] %>%
    group_by(Bezugskategorie) %>%
    summarise(
      !!paste0("Quellensteuerertrag ", year_start) := round_maths(sum(steuer_netto, na.rm = TRUE)),
      !!paste0("Anzahl Veranlagungen ", year_start, " (rechte Skala)") := n(),
      .groups = "drop"
    )

  # Berechnung für year_end
  df_end <- df[df$steuerjahr == year_end, ] %>%
    group_by(Bezugskategorie) %>%
    summarise(
      !!paste0("Quellensteuerertrag ", year_end) := round_maths(sum(steuer_netto, na.rm = TRUE)),
      !!paste0("Anzahl Veranlagungen ", year_end, " (rechte Skala)") := n(),
      .groups = "drop"
    )

  # Join beide Jahre
  df_final <- full_join(df_start, df_end, by = "Bezugskategorie") %>%
    arrange(Bezugskategorie)

  # Transpose table: columns <-> rows
  df_transposed <- df_final %>%
    column_to_rownames(var = "Bezugskategorie") %>%
    t() %>%
    as.data.frame() %>%
    rownames_to_column(var = " ")

  # Spaltennamen anpassen
 colnames(df_transposed) <- gsub("Bezüger von Kapitalleistungen", "Kapitalleistungen", colnames(df_transposed))
 colnames(df_transposed) <- gsub("Erwerbseinkommen", "Erwerb", colnames(df_transposed))
 colnames(df_transposed) <- gsub("Versicherungsleistungen", "Versicherung", colnames(df_transposed))
 colnames(df_transposed) <- gsub("Künstler, Sportler, Referenten", "Künstler, Sport", colnames(df_transposed))
 colnames(df_transposed) <- gsub("Verwaltungsräte & Mitarbeiterbeteiligungen", "Verwaltungsräte", colnames(df_transposed))
 colnames(df_transposed) <- gsub("Rentenbezüger", "Renten", colnames(df_transposed))
 colnames(df_transposed) <- gsub("Grenzgänger", "Grenzgänger Deutschland u.a.", colnames(df_transposed))

  # Spaltenreihenfolge definieren (optional, passend zur Vorlage)
  spalten_reihenfolge <- c(
    " ", "Erwerb", "Versicherung", "Grenzgänger Deutschland u.a.",
    "Künstler, Sport", "Verwaltungsräte", "Renten", "Kapitalleistungen"
  )
  df_transposed <- df_transposed[, spalten_reihenfolge]

  # Zeilenreihenfolge anpassen
  zeilen_reihenfolge <- c(
    paste0("Quellensteuerertrag ", year_start),
    paste0("Quellensteuerertrag ", year_end),
    paste0("Anzahl Veranlagungen ", year_start, " (rechte Skala)"),
    paste0("Anzahl Veranlagungen ", year_end, " (rechte Skala)")
  )
  df_transposed <- df_transposed[match(zeilen_reihenfolge, df_transposed$` `), ]

  # Save result
  jahr <- format(Sys.Date(), "%Y")
  ordner_pfad <- paste0(global_path, jahr, "/")
  if (!dir.exists(ordner_pfad)) {
    dir.create(ordner_pfad, recursive = TRUE)
  }

  datei_pfad <- paste0(ordner_pfad, "6912.tsv")
  write.table(df_transposed,
    file = datei_pfad, sep = "\t", row.names = FALSE,
    quote = FALSE
  )

  return(cat("6912 erfolgreich berechnet "))
}
