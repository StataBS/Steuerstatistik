# The function id_6983 calculates the total value composed of three tax types
# and the taxable base (gewinn_satzbestimmend), grouped by classes.
#
# param conn A database connection object
# param year The reference tax year.

source("functions/fetch_table_data.R")
source("functions/round_maths.R")

id_6983 <- function(conn, year) {
  # Define required columns
  columns <- c(
    "steuerjahr",
    "gewinn_steuerbetrag_gesamt",
    "kapital_steuerbetrag_gesamt",
    "grundstück_steuerbetrag_gesamt",
    "gewinn_satzbestimmend"
  )

  # Fetch data
  df <- fetch_table_data(conn = conn, view = "JurP", table_name = "vVeranlagung", columns = columns)

  # Check for empty
  if (nrow(df) == 0) {
    stop("Error: The DataFrame is empty!")
  }

  # Filter for target year
  df <- df[df$steuerjahr == year, ]

  # Convert to numeric
  df$gewinn_steuerbetrag_gesamt <- as.numeric(df$gewinn_steuerbetrag_gesamt)
  df$kapital_steuerbetrag_gesamt <- as.numeric(df$kapital_steuerbetrag_gesamt)
  df$grundstück_steuerbetrag_gesamt <- as.numeric(df$grundstück_steuerbetrag_gesamt)
  df$gewinn_satzbestimmend <- as.numeric(df$gewinn_satzbestimmend)

  # Calculate total tax per record
  df$gesamtsteuer <- rowSums(df[, c(
    "gewinn_steuerbetrag_gesamt",
    "kapital_steuerbetrag_gesamt",
    "grundstück_steuerbetrag_gesamt",
    "gewinn_satzbestimmend"
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

  # Aggregieren
  df_final <- df %>%
    group_by(Klassen = Klasse) %>%
    summarise(
      Veranlagungen = n(),
      `Summe Gesamtssteuer` = round_maths(sum(gesamtsteuer, na.rm = TRUE)),
      .groups = "drop"
    ) %>%
    arrange(factor(Klassen, levels = labels)) # Reihenfolge sichern

  # Speichern
  jahr <- format(Sys.Date(), "%Y")
  ordner_pfad <- paste0(global_path, jahr, "/")
  if (!dir.exists(ordner_pfad)) {
    dir.create(ordner_pfad, recursive = TRUE)
  }

  datei_pfad <- paste0(ordner_pfad, "6983.tsv")
  write.table(df_final, file = datei_pfad, sep = "\t", row.names = FALSE, quote = FALSE)
}
