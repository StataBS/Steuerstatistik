# The function id_6908 groups taxable wealth by defined brackets and
# calculates the number of records and total wealth tax per class.
#
# param conn A database connection object
# param year The target tax year

source("functions/fetch_table_data.R")
source("functions/round_maths.R")

id_6908 <- function(conn, year) {
  
  # Define columns
  columns <- c("steuerjahr", "Vermögen_steuerbar", "Vermögen_Steuerbetrag_ktgde")
  
  # Fetch data from DB
  df <- fetch_table_data(conn, view = "sas", table_name = "veranlagungen_ab_2005_wua", columns = columns)
  
  # Check for empty result
  if (nrow(df) == 0) {
    stop("Error: The DataFrame is empty!")
  }
  
  # Filter by year
  df <- df[df$steuerjahr == year, ]
  
  # Convert to numeric
  df$Vermögen_steuerbar <- as.numeric(df$Vermögen_steuerbar)
  df$Vermögen_Steuerbetrag_ktgde <- as.numeric(df$Vermögen_Steuerbetrag_ktgde)
  
  # Klassierung
  breaks <- c(0, 1, 200000, 500000, 1000000, 2000000, Inf)
  labels <- c(
    "0",
    "1 bis 199 999",
    "200 000 bis 499 999",
    "500 000 bis 999 999",
    "1 bis 1,999 Mio.",
    "2 Mio. u.m."
  )
  df$Klasse <- cut(df$Vermögen_steuerbar, breaks = breaks, labels = labels, right = FALSE, include.lowest = TRUE)
  
  # Aggregation
  df_final <- df %>%
    group_by(Klassen = Klasse) %>%
    summarise(
      Veranlagungen = n(),
      `Summe Vermögenssteuer` = round_maths(sum(Vermögen_Steuerbetrag_ktgde, na.rm = TRUE)),
      .groups = "drop"
    ) %>%
    arrange(factor(Klassen, levels = labels))
  
  # Save result
  jahr <- format(Sys.Date(), "%Y")
  ordner_pfad <- paste0(global_path, jahr, "/")
  if (!dir.exists(ordner_pfad)) {
    dir.create(ordner_pfad, recursive = TRUE)
  }
  datei_pfad <- paste0(ordner_pfad, "6908.tsv")
  write.table(df_final, file = datei_pfad, sep = "\t", row.names = FALSE, quote = FALSE)
}
