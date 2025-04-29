# The function id_6903 calculates the average and median net wealth 
# and the total wealth tax revenue for Basel-Stadt over the last 9 years.
#
# @param conn A database connection object
# @param year Represents the target tax year for which the function 
# will retrieve and process wealth data.

source("functions/fetch_table_data.R")
source("functions/round_maths.R")

id_6903 <- function(conn, year){
  
  # Define required columns from the database
  columns <- c("Reinvermögen", "Vermögen_Steuerbetrag_ktgde", "Steuerjahr")
  
  # Fetch data from the database table
  df <- fetch_table_data(conn=conn, schema="sas", table_name="veranlagungen_ab_2005_WUA", 
                         columns = columns)
  
  # Check if the DataFrame is empty
  if (nrow(df) == 0) {
    stop("Error: The DataFrame is empty!")
  }
  
  # Create an empty result DataFrame
  df_result <- data.frame(
    Jahr = integer(),
    Mean_Reinvermögen = numeric(),
    Median_Reinvermögen = numeric(),
    Sum_Vermögen_Steuerbetrag = numeric()
  )
  
  # Loop over the last 9 years
  for (i in seq(9, 0, -1)){ 
    # Filter data for the given year
    df_filtered <- df[df$Steuerjahr == year - i, ]
    
    # Convert to numeric (ensure no errors)
    df_filtered$Reinvermögen <- as.numeric(df_filtered$Reinvermögen)
    df_filtered$Vermögen_Steuerbetrag_ktgde <- as.numeric(df_filtered$Vermögen_Steuerbetrag_ktgde)
    
    # Compute values
    mean_wealth <- round_maths(mean(df_filtered$Reinvermögen, na.rm = TRUE))
    median_wealth <- round_maths(median(df_filtered$Reinvermögen, na.rm = TRUE))
    sum_wealth_tax <- round_maths(sum(df_filtered$Vermögen_Steuerbetrag_ktgde, na.rm = TRUE))
    
    # Store results
    df_result <- rbind(df_result, data.frame(
      Jahr = year - i,
      Mean_Reinvermögen = mean_wealth,
      Median_Reinvermögen = median_wealth,
      Sum_Vermögen_Steuerbetrag = sum_wealth_tax
    ))
  }
  
  # Rename columns for better readability
  colnames(df_result) <- c("Jahr", "Mittelwert Reinvermögen", "Median Reinvermögen", "Ertrag aus Vermögenssteuer (rechte Skala)")
  
  # Get the current year for dynamic storage
  jahr <- format(Sys.Date(), "%Y")  # Gets the current year as a string
  
  # Create the storage directory if it does not exist
  ordner_pfad <- paste0(global_path, jahr, "/")  # Path for the year
  if (!dir.exists(ordner_pfad)) {
    dir.create(ordner_pfad, recursive = TRUE)
  } 
  
  # Save the final DataFrame as a TSV file
  datei_pfad <- paste0(ordner_pfad, "6903.tsv")
  write.table(df_result, file = datei_pfad, sep = "\t", row.names = FALSE, quote = FALSE)
  
  return(cat("6903 erfolgreich berechnet "))
}
