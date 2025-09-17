# The function id_6981 calculates the annual total revenue from property, capital,
# and profit taxes for the last 10 years (year - 9 to year),
# including the number of assessments per year.
#
# param conn A database connection object
# param year The target year (e.g. 2020). The function processes 10 years: year - 9 to year.

source("functions/fetch_table_data.R")
source("functions/round_maths.R")

id_6981 <- function(conn, year) {
  # Define required columns
  columns <- c(
    "Steuerjahr",
    "gewinn_steuerbetrag_gesamt",
    "kapital_steuerbetrag_gesamt",
    "grundstück_steuerbetrag_gesamt"
  )

  # Fetch data
  df <- fetch_table_data(conn = conn, view = "JurP", table_name = "vVeranlagung", columns = columns)

  # Check if the DataFrame is empty
  if (nrow(df) == 0) {
    stop("Error: The DataFrame is empty!")
  }

  # Convert to numeric
  df$gewinn_steuerbetrag_gesamt <- as.numeric(df$gewinn_steuerbetrag_gesamt)
  df$kapital_steuerbetrag_gesamt <- as.numeric(df$kapital_steuerbetrag_gesamt)
  df$grundstück_steuerbetrag_gesamt <- as.numeric(df$grundstück_steuerbetrag_gesamt)

  # Filter for the 10-year range
  df_filtered <- df[df$Steuerjahr >= year - 9 & df$Steuerjahr <= year, ]

  # Group and summarise per year
  df_final <- df_filtered %>%
    group_by(Steuerjahr) %>%
    summarise(
      "Ertrag Grundstücksteuern" = round_maths(sum(grundstück_steuerbetrag_gesamt, na.rm = TRUE)),
      "Ertrag Kapitalsteuern" = round_maths(sum(kapital_steuerbetrag_gesamt, na.rm = TRUE)),
      "Ertrag Gewinnsteuern" = round_maths(sum(gewinn_steuerbetrag_gesamt, na.rm = TRUE)),
      "Veranlagungen (rechte Skala)" = n(),
      .groups = "drop"
    ) %>%
    arrange(Steuerjahr) %>%
    rename(Jahr = Steuerjahr)

  # Save result
  jahr <- format(Sys.Date(), "%Y")
  ordner_pfad <- paste0(global_path, jahr, "/")
  if (!dir.exists(ordner_pfad)) {
    dir.create(ordner_pfad, recursive = TRUE)
  }

  datei_pfad <- paste0(ordner_pfad, "6981.tsv")
  write.table(df_final, file = datei_pfad, sep = "\t", row.names = FALSE, quote = FALSE)
}
