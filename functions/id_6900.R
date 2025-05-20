# The function id_6900 calculates the average and median income 
# and the total income tax revenue for Basel-Stadt over the last 10 years.
#
# @param conn A database connection object
# @param year Represents the target tax year for which the function 
# will retrieve and process income data.

source("functions/fetch_table_data.R")
source("functions/round_maths.R")

id_6900 <- function(conn, year){
  
  # Define required columns from the database
  columns <- c("Reineinkommen",
               "Einkommen_Steuerbetrag_ktgde",
               "Steuerjahr")
  
  # Fetch data from the database table
  df <- fetch_table_data(conn = conn,
                         schema = "sas",
                         table_name = "veranlagungen_ab_2005_WUA", 
                         columns = columns)
  
  # Check if the DataFrame is empty
  if (nrow(df) == 0) {
    stop("Error: The DataFrame is empty!")
  }
  
  # Convert necessary columns to numeric
  df$Reineinkommen <- as.numeric(df$Reineinkommen)
  df$Einkommen_Steuerbetrag_ktgde <- as.numeric(df$Einkommen_Steuerbetrag_ktgde)
  
  # Create an empty result DataFrame
  df_result <- data.frame(
    Jahr = integer(),
    Mean_Reineinkommen = numeric(),
    Median_Reineinkommen = numeric(),
    Sum_Einkommen_Steuerbetrag = numeric()
  )
  
  # Loop over the last 9 years
  for (i in seq(9, 0, -1)){ 
    #  Filter data for the given year
    df_filtered <- df[df$Steuerjahr == year - i, ]
    
    df_result <- rbind(df_result, data.frame(
      Jahr = year - i,
      Mean_Reineinkommen = round_maths(mean(df_filtered$Reineinkommen,na.rm = TRUE)),
      Median_Reineinkommen = round_maths(median(df_filtered$Reineinkommen, na.rm = TRUE)),
      Sum_Einkommen_Steuerbetrag = round_maths(sum(df_filtered$Einkommen_Steuerbetrag_ktgde, na.rm = TRUE))
    ))
  }
  
  colnames(df_result) <- c("Jahr",
                           "Mittelwert Reineinkommen",
                           "Median Reineinkommen",
                           "Ertrag aus Einkommenssteuer (rechte Skala)")
  
  #  Get the current year for dynamic storage
  jahr <- format(Sys.Date(), "%Y")  # Gets the current year as a string
  
  #  Create the storage directory if it does not exist
  ordner_pfad <- paste0(global_path, jahr, "/")  # Path for the year
  if (!dir.exists(ordner_pfad)) {
    dir.create(ordner_pfad, recursive = TRUE)
  } 
  
  #  Save the final DataFrame as a TSV file
  datei_pfad <- paste0(ordner_pfad, "6900.tsv")
  write.table(df_result, file = datei_pfad, sep = "\t", row.names = FALSE,
              quote = FALSE)
  
  return(cat("6900 erfolgreich berechnet "))
}