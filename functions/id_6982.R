# The function id_6982 calculates the distribution of total tax revenue
# across defined tax amount classes, based on JurP.vVeranlagung.
#
# param conn A database connection object
# param year The reference tax year. Only this year will be considered.

source("functions/fetch_table_data.R")

id_6982 <- function(conn, year) {
  # Define required columns
  columns <- c(
    "steuerjahr",
    "gewinn_steuerbetrag_gesamt",
    "kapital_steuerbetrag_gesamt",
    "grundstück_steuerbetrag_gesamt"
  )

  # Fetch data
  df <- fetch_table_data(conn = conn, view = "JurP", table_name = "vVeranlagung", columns = columns)

  # Check if empty
  if (nrow(df) == 0) {
    stop("Error: The DataFrame is empty!")
  }

  # Filter for selected year
  df <- df[df$steuerjahr == year, ]

  # Convert to numeric
  df$gewinn_steuerbetrag_gesamt <- as.numeric(df$gewinn_steuerbetrag_gesamt)
  df$kapital_steuerbetrag_gesamt <- as.numeric(df$kapital_steuerbetrag_gesamt)
  df$grundstück_steuerbetrag_gesamt <- as.numeric(df$grundstück_steuerbetrag_gesamt)

  # Calculate total tax per record
  df$gesamtsteuer <- rowSums(df[, c(
    "gewinn_steuerbetrag_gesamt",
    "kapital_steuerbetrag_gesamt",
    "grundstück_steuerbetrag_gesamt"
  )], na.rm = TRUE)

  # Define class breaks and labels exactly as in your table
  breaks <- c(0, 1, 5000, 10000, 20000, 50000, 100000, 1000000, Inf)
  labels <- c(
    "0",
    "1 bis 4 999",
    "5 000 bis 9 999",
    "10 000 bis 19 999",
    "20 000 bis 49 999",
    "50 000 bis 99 999",
    "100 000 bis 999 999",
    "1 Mio. u.m."
  )

  # Assign classes using cut (left-inclusive, right-exclusive)
  df$Klasse <- cut(df$gesamtsteuer, breaks = breaks, labels = labels, right = FALSE, include.lowest = TRUE)

  # Group and aggregate
  df_final <- df %>%
    group_by(Klassen = Klasse) %>%
    summarise(
      Veranlagungen = n(),
      `Summe Gesamtsteuer` = round(sum(gesamtsteuer, na.rm = TRUE)),
      .groups = "drop"
    ) %>%
    arrange(factor(Klassen, levels = labels)) # Force defined order

  # Save result
  jahr <- format(Sys.Date(), "%Y")
  ordner_pfad <- paste0(global_path, jahr, "/")
  if (!dir.exists(ordner_pfad)) {
    dir.create(ordner_pfad, recursive = TRUE)
  }

  datei_pfad <- paste0(ordner_pfad, "6982.tsv")
  write.table(df_final, file = datei_pfad, sep = "\t", row.names = FALSE, quote = FALSE)
}
