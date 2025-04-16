# The function id_6912 calculates the total withholding tax and number of tax cases
# grouped by income category (Bezugskategorie) for the selected year and 9 years before.
#
# @param conn A database connection object
# @param year The reference tax year (e.g. 2022). The function will compare it to year - 9.

source("functions/fetch_table_data.R")

id_6912 <- function(conn, year){
  
  # Define columns
  columns <- c("steuerjahr", "steuer_netto", "Bezugskategorie", "anteil_bund")
  
  # Fetch data
  df <- fetch_table_data(conn = conn, schema = "sasqst", table_name = "quellensteuer_zeitreihe", columns = columns)
  
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
      !!paste0("Quellensteuerertrag ", year_start) := round(sum(steuer_netto, na.rm = TRUE)),
      !!paste0("Veranlagungen ", year_start, " (rechte Skala)") := n(),
      .groups = "drop"
    )
  
  # Berechnung für year_end
  df_end <- df[df$steuerjahr == year_end, ] %>%
    group_by(Bezugskategorie) %>%
    summarise(
      !!paste0("Quellensteuerertrag ", year_end) := round(sum(steuer_netto, na.rm = TRUE)),
      !!paste0("Veranlagungen ", year_end, " (rechte Skala)") := n(),
      .groups = "drop"
    )
  
  # Join beide Jahre
  df_final <- full_join(df_start, df_end, by = "Bezugskategorie") %>%
    arrange(Bezugskategorie)
  
  # Save result
  jahr <- format(Sys.Date(), "%Y")
  ordner_pfad <- paste0(global_path, jahr, "/")
  if (!dir.exists(ordner_pfad)) {
    dir.create(ordner_pfad, recursive = TRUE)
  }
  
  datei_pfad <- paste0(ordner_pfad, "6912.tsv")
  write.table(df_final, file = datei_pfad, sep = "\t", row.names = FALSE, quote = FALSE)
}
