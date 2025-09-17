# The function id_6907 groups income by 'Einkommen_steuerbar' brackets
# and calculates the number of records and total taxed income.
#
# param conn A database connection object
# param year The target tax year

source("functions/fetch_table_data.R")
source("functions/round_maths.R")

id_6907 <- function(conn, year) {
  
  # Define columns
  columns <- c("steuerjahr", "Einkommen_steuerbar", "Einkommen_Steuerbetrag_ktgde")
  
  # Fetch from DB
  df <- fetch_table_data(conn, view = "sas", table_name = "veranlagungen_ab_2005_wua", columns = columns)
  
  # Check empty
  if (nrow(df) == 0) {
    stop("Error: The DataFrame is empty!")
  }
  
  # Filter year
  df <- df[df$steuerjahr == year, ]
  
  # Convert
  df$Einkommen_steuerbar <- as.numeric(df$Einkommen_steuerbar)
  df$Einkommen_Steuerbetrag_ktgde <- as.numeric(df$Einkommen_Steuerbetrag_ktgde)
  
  # Klassierung
  breaks <- c(0, 1, 25000, 50000, 75000, 100000, 200000, Inf)
  labels <- c(
    "0",
    "1 bis 24 999",
    "25 000 bis 49 999",
    "50 000 bis 74 999",
    "75 000 bis 99 999",
    "100 000 bis 199 999",
    "200 000 und mehr"
  )
  df$Klasse <- cut(df$Einkommen_steuerbar, breaks = breaks, labels = labels, right = FALSE, include.lowest = TRUE)
  
  # Aggregation
  df_final <- df %>%
    group_by(Klassen = Klasse) %>%
    summarise(
      Veranlagungen = n(),
      `Summe Einkommenssteuer` = round_maths(sum(Einkommen_Steuerbetrag_ktgde, na.rm = TRUE)),
      .groups = "drop"
    ) %>%
    arrange(factor(Klassen, levels = labels))
  
  # Save
  jahr <- format(Sys.Date(), "%Y")
  ordner_pfad <- paste0(global_path, jahr, "/")
  if (!dir.exists(ordner_pfad)) {
    dir.create(ordner_pfad, recursive = TRUE)
  }
  datei_pfad <- paste0(ordner_pfad, "6907.tsv")
  write.table(df_final, file = datei_pfad, sep = "\t", row.names = FALSE, quote = FALSE)
}
