# Load necessary functions
source("functions/config.R")
source("functions/db_connection.R")
source("functions/close_connection.R")
source("functions/bootstrap_packages.R")



# Define valid indicator IDs
valid_indicator_ids <- c(6899, 6900, 6901, 6902,6903 , 6904, 6905, 6906, 6909, 6911, 6912, 6980)

# Function to process and validate input indicator IDs
process_input_ids <- function(input) {
  input_clean <- gsub(" ", "", input)  # Remove spaces
  input_clean <- gsub("c\\(|\\)", "", input_clean)  # Remove 'c()' if present
  ids <- as.numeric(unlist(strsplit(input_clean, ",")))  # Convert to numeric vector
  
  # Check if the input is empty
  if (length(ids) == 0 || all(is.na(ids))) {
    stop("❌ Fehler: Es wurden keine gültigen IDs eingegeben. Bitte gib mindestens eine gültige ID ein.")
  }
  
  
  # Check for invalid (non-numeric) entries
  if (any(is.na(ids))) {
    invalid_ids <- unlist(strsplit(input_clean, ","))[is.na(ids)]
    stop(sprintf("❌ Ungültige IDs gefunden: %s. Bitte nur Zahlen eingeben.", paste(invalid_ids, collapse = ", ")))
  }
  
  # Check if IDs are valid
  invalid_provided_ids <- ids[!ids %in% valid_indicator_ids]
  if (length(invalid_provided_ids) > 0) {
    stop(sprintf(
      "❌ Die folgenden IDs sind ungültig oder existieren nicht: %s.\n  Bitte gib gültige IDs ein (gültige IDs: %s).",
      paste(invalid_provided_ids, collapse = ", "),
      paste(valid_indicator_ids, collapse = ", ")
    ))
  }
  
  return(ids)
}

# Main function to calculate indicators
calculate_indicator <- function() {
  
  # Get command-line arguments
  args <- commandArgs(trailingOnly = TRUE)
  
  # Check if year and indicator IDs are provided
  if (length(args) < 2) {
    stop("❌ Fehler: Bitte gib das Jahr und die Indikator-IDs als Argumente ein.")
  }
  
  # Process and validate year input
  year <- as.numeric(args[1])
  if (is.na(year) || year < 2000 || year > as.numeric(format(Sys.Date(), "%Y"))) {
    stop("❌ Fehler: Bitte gib eine gültige Jahreszahl (z.B. 2024) ein.")
  }
  
  # Process and validate indicator IDs
  ids <- process_input_ids(args[2])
  
  # Establish database connection
  conn <- db_connection()
  
  # Calculate each selected indicator 
  
  for (id in as.character(ids)) {
    file_path <- paste0("functions/id_", id, ".R")
    cat(sprintf("\n🔄 Berechne ID %s...\n", id))
    
    if (file.exists(file_path)) {
      tryCatch({
        source(file_path)
        fun_name <- paste0("id_", id)
        if (exists(fun_name)) {
          get(fun_name)(conn, year)
          cat(sprintf("✅ ID %s erfolgreich berechnet.\n", id))
        } else {
          cat(sprintf("❌ Funktion '%s' nicht gefunden.\n", fun_name))
        }
      }, error = function(e) {
        cat(sprintf("❌ Fehler bei ID %s: %s\n", id, e$message))
      })
    } else {
      cat(sprintf("⚠️ Datei für ID %s nicht gefunden: %s\n", id, file_path))
    }
  }
  
  
  # Close the database connection
  close_connection(conn)
  cat("✅ Der Prozess ist abgeschlossen.\n")
}

calculate_indicator()

