# The function id_6906 calculates the total income tax, total wealth tax,
# and the number of tax assessments for each neighborhood in Basel-Stadt
# for the given year and 9 years before.
#
# param conn A database connection object
# param year Represents the target tax year for which the function
#        will retrieve and process tax data.

source("functions/fetch_table_data.R")
source("functions/round_maths.R")

id_6906 <- function(conn, year) {
  # Define required columns from the database
  columns <- c(
    "Einkommen_Steuerbetrag_ktgde",
    "Vermögen_Steuerbetrag_ktgde",
    "wohnviertel_id_kdm",
    "wohnviertel_name",
    "Steuerjahr"
  )

  # Fetch data from the database table
  df <- fetch_table_data(
    conn = conn,
    view = "sas",
    table_name = "veranlagungen_ab_2005_WUA",
    columns = columns
  )

  # Check if the DataFrame is empty
  if (nrow(df) == 0) {
    stop("Error: The DataFrame is empty!")
  }

  # Convert necessary columns to numeric
  df$Einkommen_Steuerbetrag_ktgde <- as.numeric(df$Einkommen_Steuerbetrag_ktgde)
  df$Vermögen_Steuerbetrag_ktgde <- as.numeric(df$Vermögen_Steuerbetrag_ktgde)

  # Define the two years to compare
  year_start <- year - 9
  year_end <- year

  # Filter and summarise for year_start
  df_start <- df[df$Steuerjahr == year_start, ] %>%
    group_by(wohnviertel_id_kdm, wohnviertel_name) %>%
    summarise(
      !!paste0("Einkommenssteuer ", year_start) := round_maths(sum(Einkommen_Steuerbetrag_ktgde, na.rm = TRUE)),
      !!paste0("Vermögenssteuer ", year_start) := round_maths(sum(Vermögen_Steuerbetrag_ktgde, na.rm = TRUE)),
      !!paste0("Anzahl Veranlagungen ", year_start, " (rechte Skala)") := n(),
      .groups = "drop"
    )

  # Filter and summarise for year_end
  df_end <- df[df$Steuerjahr == year_end, ] %>%
    group_by(wohnviertel_id_kdm, wohnviertel_name) %>%
    summarise(
      !!paste0("Einkommenssteuer ", year_end) := round_maths(sum(Einkommen_Steuerbetrag_ktgde, na.rm = TRUE)),
      !!paste0("Vermögenssteuer ", year_end) := sum(Vermögen_Steuerbetrag_ktgde, na.rm = TRUE),
      !!paste0("Anzahl Veranlagungen ", year_end, " (rechte Skala)") := n(),
      .groups = "drop"
    )

  # Merge by ID and name
  df_final <- full_join(df_start, df_end, by = c(
    "wohnviertel_id_kdm",
    "wohnviertel_name"
  )) %>%
    mutate(
      wohnviertel_name = case_when(
        wohnviertel_name == "Altstadt Grossbasel" ~ "Altstadt GB",
        wohnviertel_name == "Altstadt Kleinbasel" ~ "Altstadt KB",
        wohnviertel_name == "Kleinhüningen" ~ "Kleinhüning.",
        TRUE ~ wohnviertel_name
      )
    ) %>%
    arrange(wohnviertel_id_kdm) %>%
    select(
      wohnviertel_name,
      paste0("Einkommenssteuer ", year_start),
      paste0("Einkommenssteuer ", year_end),
      paste0("Vermögenssteuer ", year_start),
      paste0("Vermögenssteuer ", year_end),
      paste0("Anzahl Veranlagungen ", year_start, " (rechte Skala)"),
      paste0("Anzahl Veranlagungen ", year_end, " (rechte Skala)")
    )

  names(df_final)[names(df_final) == "wohnviertel_name"] <- ""
  
  # Save result
  jahr <- format(Sys.Date(), "%Y")
  ordner_pfad <- paste0(global_path, jahr, "/")
  if (!dir.exists(ordner_pfad)) {
    dir.create(ordner_pfad, recursive = TRUE)
  }

  datei_pfad <- paste0(ordner_pfad, "6906.tsv")
  write.table(df_final,
    file = datei_pfad, sep = "\t", row.names = FALSE,
    quote = FALSE
  )
}
