# The function id_6980 calculates the total and average tax revenue 
# per neighborhood in Basel-Stadt for a given year.
#
# @param conn A database connection object
# @param year Represents the tax year for which the function will retrieve and process data.

source("functions/fetch_table_data.R")

id_6980 <- function(conn, year){
  
  # Define required columns from the database
  columns <- c("wohnviertel_id_kdm", 
               "wohnviertel_name", 
               "Einkommen_Steuerbetrag_ktgde", 
               "Vermögen_Steuerbetrag_ktgde", 
               "Steuerjahr")
  
  # Fetch data
  df <- fetch_table_data(conn=conn, schema="sas", table_name="veranlagungen_ab_2005_WUA", 
                         columns = columns)
  
  # Check if the DataFrame is empty
  if (nrow(df) == 0) {
    stop("Error: The DataFrame is empty!")
  }
  
  # Filter for the selected year
  df <- df[df$Steuerjahr == year, ]
  
  # Convert tax columns to numeric
  df$Einkommen_Steuerbetrag_ktgde <- as.numeric(df$Einkommen_Steuerbetrag_ktgde)
  df$Vermögen_Steuerbetrag_ktgde <- as.numeric(df$Vermögen_Steuerbetrag_ktgde)
  
  # Calculate total tax revenue (income + wealth tax)
  df$Gesamtsteuerertrag <- df$Einkommen_Steuerbetrag_ktgde + df$Vermögen_Steuerbetrag_ktgde
  
  # Aggregate results per neighborhood
  df_result <- df %>%
    group_by(Wohnviertel_ID = wohnviertel_id_kdm,
             Wohnviertel = wohnviertel_name) %>%
    summarise(
      "Mittelwert Gesamtsteuerertrag" = round(mean(Gesamtsteuerertrag, na.rm = TRUE)),
      Gesamtsteuerertrag = sum(Gesamtsteuerertrag, na.rm = TRUE),
      Einkommenssteuer = sum(Einkommen_Steuerbetrag_ktgde, na.rm = TRUE),
      Vermögenssteuer = sum(Vermögen_Steuerbetrag_ktgde, na.rm = TRUE),
      .groups = "drop"
    )
  
  # Create folder path for saving results
  jahr <- format(Sys.Date(), "%Y")
  ordner_pfad <- paste0(global_path, jahr, "/")
  
  if (!dir.exists(ordner_pfad)) {
    dir.create(ordner_pfad, recursive = TRUE)
  }
  
  # Save result as TSV file
  datei_pfad <- paste0(ordner_pfad, "6980.tsv")
  write.table(df_result, file = datei_pfad, sep = "\t", row.names = FALSE, quote = FALSE)
}
