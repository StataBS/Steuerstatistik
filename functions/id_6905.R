# The function id_6905 calculates the median net worth per neighborhood and
# the overall median net worth for Basel-Stadt.
# 
# @param conn A database connection object
# @param year Represents the target tax year for which the function will retrieve and process net worth data.

source("functions/fetch_table_data.R")
source("functions/round_maths.R")

id_6905 <- function(conn, year) {
  
  # Define required columns from the database
  columns <- c("Reinvermögen", "wohnviertel_id_kdm", "wohnviertel_name", "Steuerjahr")
  
  # Fetch data
  df <- fetch_table_data(conn=conn, schema="sas", table_name="veranlagungen_ab_2005_WUA", 
                         columns = columns)
  
  # Check if the DataFrame is empty
  if (nrow(df) == 0) {
    stop("Error: The DataFrame is empty!")
  }
  
  # Filter data for the given year
  df_end <- df[df$Steuerjahr == year, ]
  df_end$Reinvermögen <- as.numeric(df_end$Reinvermögen)
  m_end <- round_maths(median(df_end$Reinvermögen, na.rm = TRUE))
  
  # Filter data for (year - 9)
  df_start <- df[df$Steuerjahr == year - 9, ]
  df_start$Reinvermögen <- as.numeric(df_start$Reinvermögen)
  m_start <- round_maths(median(df_start$Reinvermögen, na.rm = TRUE))
  
  # Median net worth per residential area
  median_end <- df_end %>%
    group_by(wohnviertel_id_kdm, wohnviertel_name) %>%
    summarise(!!paste0("Median ", year) := round_maths(median(Reinvermögen, na.rm = TRUE)), .groups = "drop")
  
  median_start <- df_start %>%
    group_by(wohnviertel_id_kdm, wohnviertel_name) %>%
    summarise(!!paste0("Median ", year - 9) := round_maths(median(Reinvermögen, na.rm = TRUE)), .groups = "drop")
  
  # Merge and add Basel-Stadt medians
  df_final <- full_join(median_start, median_end, by = c("wohnviertel_id_kdm", "wohnviertel_name")) %>%
    mutate(
      !!paste0("Median Basel-Stadt ", year - 9) := m_start,
      !!paste0("Median Basel-Stadt ", year) := m_end
    ) %>%
    arrange(wohnviertel_id_kdm) %>%
    select(
      wohnviertel_name,
      paste0("Median ", year - 9),
      paste0("Median Basel-Stadt ", year - 9),
      paste0("Median ", year),
      paste0("Median Basel-Stadt ", year)
    )
  
  # Save result
  jahr <- format(Sys.Date(), "%Y")
  ordner_pfad <- paste0(global_path, jahr, "/")
  if (!dir.exists(ordner_pfad)) {
    dir.create(ordner_pfad, recursive = TRUE)
  } 
  
  datei_pfad <- paste0(ordner_pfad, "6905.tsv")
  write.table(df_final, file = datei_pfad, sep = "\t", row.names = FALSE, quote = FALSE)
  
  return(cat("6905 erfolgreich berechnet "))
}
