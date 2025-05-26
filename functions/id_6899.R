# Noch nicht vollständig. Muss auf Uli warten






# The function id_6899 calculates index values for Basel-Stadt over time
# with index = 100 for the base year (year - 9).
#
# @param conn A database connection object
# @param year The selected target year (e.g. 2021). Index starts at year - 9.

source("functions/fetch_table_data.R")

id_6899 <- function(conn, year) {
  # Define required columns
  columns <- c(
    "Steuerjahr", "Reineinkommen", "Reinvermögen",
    "Einkommen_Steuerbetrag_ktgde", "Vermögen_Steuerbetrag_ktgde"
  )

  # Fetch data
  df <- fetch_table_data(
    conn = conn, schema = "sas", table_name = "veranlagungen_ab_2005_WUA",
    columns = columns
  )

  # Check if the DataFrame is empty
  if (nrow(df) == 0) {
    stop("Error: The DataFrame is empty!")
  }

  # Convert necessary columns to numeric
  df$Reineinkommen <- as.numeric(df$Reineinkommen)
  df$Reinvermögen <- as.numeric(df$Reinvermögen)
  df$Einkommen_Steuerbetrag_ktgde <- as.numeric(df$Einkommen_Steuerbetrag_ktgde)
  df$Vermögen_Steuerbetrag_ktgde <- as.numeric(df$Vermögen_Steuerbetrag_ktgde)

  # Define year range
  start_year <- year - 9
  end_year <- year

  # Filter to years of interest
  df <- df[df$Steuerjahr >= start_year & df$Steuerjahr <= end_year, ]

  # Aggregate totals per year
  df_summary <- df %>%
    group_by(Steuerjahr) %>%
    summarise(
      Veranlagungen = n(),
      Reineinkommen = sum(Reineinkommen, na.rm = TRUE),
      Reinvermögen = sum(Reinvermögen, na.rm = TRUE),
      Einkommenssteuer = sum(Einkommen_Steuerbetrag_ktgde, na.rm = TRUE),
      Vermögenssteuer = sum(Vermögen_Steuerbetrag_ktgde, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(`Einkommens- und Vermögenssteuerertrag` = Einkommenssteuer + Vermögenssteuer) %>%
    select(Steuerjahr, Veranlagungen, Reineinkommen, Reinvermögen, `Einkommens- und Vermögenssteuerertrag`)

  # Index calculation: divide by base year values and multiply by 100
  base_values <- df_summary[df_summary$Steuerjahr == start_year, -1]

  df_index <- df_summary %>%
    mutate(across(-Steuerjahr, ~ round(.x / base_values[[cur_column()]] * 100, 1)))

  # Rename Steuerjahr to row index
  colnames(df_index)[1] <- "Jahr"

  # Save result
  jahr <- format(Sys.Date(), "%Y")
  ordner_pfad <- paste0(global_path, jahr, "/")
  if (!dir.exists(ordner_pfad)) {
    dir.create(ordner_pfad, recursive = TRUE)
  }

  datei_pfad <- paste0(ordner_pfad, "6899.tsv")
  write.table(df_index, file = datei_pfad, sep = "\t", row.names = FALSE, quote = FALSE)
}
