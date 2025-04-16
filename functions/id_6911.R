# The function id_6911 calculates the total withholding tax (Quellensteuer)
# and the number of tax cases per neighborhood for the selected year and 9 years before.
#
# @param conn A database connection object
# @param year The reference tax year (e.g. 2022). The function will compare it to year - 9.

source("functions/fetch_table_data.R")

id_6911 <- function(conn, year){
  
  # Define required columns
  columns <- c("wohnviertel_id", "steuer_netto", "wohnviertel_bez", "steuerjahr")
  
  # Fetch data from the database
  df <- fetch_table_data(conn=conn, schema="sasqst", table_name="quellensteuer_zeitreihe", 
                         columns = columns)
  
  # Check if the DataFrame is empty
  if (nrow(df) == 0) {
    stop("Error: The DataFrame is empty!")
  }
  
  # Remove row where wohnviertel_bez is "Keine Angabe"
  df <- df[df$wohnviertel_bez != "keine Angabe", ]
  
  # Convert steuer_netto to numeric
  df$steuer_netto <- as.numeric(df$steuer_netto)
  
  # Define years
  year_start <- year - 9
  year_end <- year
  
  # Calculate total Quellensteuer for year_start
  q_start <- df[df$steuerjahr == year_start, ] %>%
    group_by(wohnviertel_id, wohnviertel_bez) %>%
    summarise(!!paste0("Quellensteuerertrag ", year_start) := round(sum(steuer_netto, na.rm = TRUE)),
              !!paste0("Veranlagungen ", year_start, " (rechte Skala)") := n(),
              .groups = "drop")
  
  # Calculate total Quellensteuer for year_end
  q_end <- df[df$steuerjahr == year_end, ] %>%
    group_by(wohnviertel_id, wohnviertel_bez) %>%
    summarise(!!paste0("Quellensteuerertrag ", year_end) := round(sum(steuer_netto, na.rm = TRUE)),
              !!paste0("Veranlagungen ", year_end, " (rechte Skala)") := n(),
              .groups = "drop")
  
  # Merge both years by neighborhood
  df_final <- full_join(q_start, q_end, by = c("wohnviertel_id", "wohnviertel_bez"))
  
  # Set column order
  df_final <- df_final %>%
    select(
      wohnviertel_id,
      wohnviertel_bez,
      paste0("Quellensteuerertrag ", year_start),
      paste0("Quellensteuerertrag ", year_end),
      paste0("Veranlagungen ", year_start, " (rechte Skala)"),
      paste0("Veranlagungen ", year_end, " (rechte Skala)")
    )%>%
    arrange(wohnviertel_id)
  
  # Save result as TSV
  jahr <- format(Sys.Date(), "%Y")
  ordner_pfad <- paste0(global_path, jahr, "/")
  
  if (!dir.exists(ordner_pfad)) {
    dir.create(ordner_pfad, recursive = TRUE)
  }
  
  datei_pfad <- paste0(ordner_pfad, "6911.tsv")
  write.table(df_final, file = datei_pfad, sep = "\t", row.names = FALSE, quote = FALSE)
}
