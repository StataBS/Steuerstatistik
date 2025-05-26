# The function id_6909 calculates the total revenue from income tax and wealth tax
# for each neighborhood in Basel-Stadt and the entire canton for the given year
# and 9 years before.
#
# param conn A database connection object
# param year Represents the target tax year for which the function
#        will retrieve and process tax data.

source("functions/fetch_table_data.R")

id_6909 <- function(conn, year) {
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

  # Funktion zur Berechnung des Gesamtertrags für Wohnviertel
  calculate_revenue <- function(df, year) {
    df %>%
      filter(Steuerjahr == year) %>%
      group_by(wohnviertel_id_kdm, wohnviertel_name) %>%
      summarise(
        !!paste0("Ertrag ", year) := sum(
          Einkommen_Steuerbetrag_ktgde +
            Vermögen_Steuerbetrag_ktgde,
          na.rm = TRUE
        ),
        .groups = "drop"
      )
  }

  # Berechnung des Ertrags für Wohnviertel für beide Jahre
  df_start <- calculate_revenue(df, year_start)
  df_end <- calculate_revenue(df, year_end)

  # Funktion zur Berechnung des Gesamtertrags für den Kanton Basel-Stadt (BS)
  calculate_revenue_bs <- function(df, year) {
    df %>%
      filter(Steuerjahr == year) %>%
      summarise(!!paste0("Ertrag Basel-Stadt ", year, " (rechte Skala)") :=
        sum(Einkommen_Steuerbetrag_ktgde + Vermögen_Steuerbetrag_ktgde, na.rm = TRUE))
  }

  # Gesamtertrag für Basel-Stadt
  ertrag_bs_start <- calculate_revenue_bs(df, year_start)
  ertrag_bs_end <- calculate_revenue_bs(df, year_end)

  # Füge die Erträge zusammen
  df_final <- full_join(df_start, df_end, by = c(
    "wohnviertel_id_kdm",
    "wohnviertel_name"
  )) %>%
    mutate(
      !!paste0("Ertrag Basel-Stadt ", year_start, " (rechte Skala)") := ertrag_bs_start[[1]],
      !!paste0("Ertrag Basel-Stadt ", year_end, " (rechte Skala)") := ertrag_bs_end[[1]]
    ) %>%
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
      paste0("Ertrag ", year_start),
      paste0("Ertrag Basel-Stadt ", year_start, " (rechte Skala)"),
      paste0("Ertrag ", year_end),
      paste0("Ertrag Basel-Stadt ", year_end, " (rechte Skala)")
    )

  names(df_final)[names(df_final) == "wohnviertel_name"] <- ""
  
  # Save result
  jahr <- format(Sys.Date(), "%Y")
  ordner_pfad <- paste0(global_path, jahr, "/")
  if (!dir.exists(ordner_pfad)) {
    dir.create(ordner_pfad, recursive = TRUE)
  }

  datei_pfad <- paste0(ordner_pfad, "6909.tsv")
  write.table(df_final,
    file = datei_pfad, sep = "\t", row.names = FALSE,
    quote = FALSE
  )
}
