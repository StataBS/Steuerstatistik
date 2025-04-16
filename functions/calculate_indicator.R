# Load necessary functions
source("function/config.R")
source("functions/db_connection.R")
source("functions/close_connection.R")



# Define valid indicator IDs
valid_indicator_ids <- c(6899, 6900, 6901, 6902,6903 , 6904, 6905, 6906, 6909, 6911, 6912, 6980)

# Function to process and validate input indicator IDs
process_input_ids <- function(input) {
  input_clean <- gsub(" ", "", input)  # Remove spaces
  input_clean <- gsub("c\\(|\\)", "", input_clean)  # Remove 'c()' if present
  ids <- as.numeric(unlist(strsplit(input_clean, ",")))  # Convert to numeric vector
  
  # Check if the input is empty
  if (length(ids) == 0 || all(is.na(ids))) {
    stop("Fehler: Es wurden keine gültigen IDs eingegeben. Bitte gib mindestens eine gültige ID ein.")
  }
  
  
  # Check for invalid (non-numeric) entries
  if (any(is.na(ids))) {
    invalid_ids <- unlist(strsplit(input_clean, ","))[is.na(ids)]
    stop(sprintf("Ungültige IDs gefunden: %s. Bitte nur Zahlen eingeben.", paste(invalid_ids, collapse = ", ")))
  }
  
  # Check if IDs are valid
  invalid_provided_ids <- ids[!ids %in% valid_indicator_ids]
  if (length(invalid_provided_ids) > 0) {
    stop(sprintf(
      "Die folgenden IDs sind ungültig oder existieren nicht: %s.\n  Bitte gib gültige IDs ein (gültige IDs: %s).",
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
    stop("Fehler: Bitte gib das Jahr und die Indikator-IDs als Argumente ein.")
  }
  
  # Process and validate year input
  year <- as.numeric(args[1])
  if (is.na(year) || year < 2000 || year > as.numeric(format(Sys.Date(), "%Y"))) {
    stop("Fehler: Bitte gib eine gültige Jahreszahl (z.B. 2024) ein.")
  }
  
  # Process and validate indicator IDs
  indicator_ids <- process_input_ids(args[2])
  
  # Establish database connection
  conn <- db_connection()
  
  # Calculate each selected indicator with error handling
  
  if (6899 %in% indicator_ids) {
    cat("Berechne ID 6899: Indexierte Entwicklung für Basel-Stadt\n")
    tryCatch({
      source("functions/id_6899.R")
      id_6899(conn, year)
      cat("✅ ID 6899 erfolgreich berechnet.\n")
    }, error = function(e) {
      cat(sprintf("❌ Fehler bei ID 6899: %s\n", e$message))
    })
  }
  
  if (6900 %in% indicator_ids) {
    cat("Berechne ID 6900 \n")
    tryCatch({
      source("functions/id_6900.R")
      id_6900(conn, year)
      cat("✅ ID 6900 erfolgreich berechnet.\n")
    }, error = function(e) {
      cat(sprintf("❌ Fehler bei ID 6900: %s\n", e$message))
    })
  }
  
  if (6901 %in% indicator_ids) {
    cat("ID 6901 wird berechnet")
    tryCatch({
      source("functions/id_6901.R")
      id_6901(conn, year)
      cat("✅ ID 6901 erfolgreich berechnet.\n")
    }, error = function(e) {
      cat(sprintf("❌ Fehler bei ID 6901: %s\n", e$message))
    })
  }

  if (6902 %in% indicator_ids) {
    cat("ID 6902 wird berechnet")
    tryCatch({
      source("functions/id_6902.R")
      id_6902(conn, year)
      cat("✅ ID 6902 erfolgreich berechnet.\n")
    }, error = function(e) {
      cat(sprintf("❌ Fehler bei ID 6902: %s\n", e$message))
    })
  }
  
  if (6903 %in% indicator_ids) {
    cat("ID 6903 wird berechnet")
    tryCatch({
      source("functions/id_6903.R")
      id_6903(conn, year)
      cat("✅ ID 6903 erfolgreich berechnet.\n")
    }, error = function(e) {
      cat(sprintf("❌ Fehler bei ID 6903: %s\n", e$message))
    })
  }
  
  if (6904 %in% indicator_ids) {
    cat("ID 6904 wird berechnet")
    tryCatch({
      source("functions/id_6904.R")
      id_6904(conn, year)
      cat("✅ ID 6904 erfolgreich berechnet.\n")
    }, error = function(e) {
      cat(sprintf("❌ Fehler bei ID 6904: %s\n", e$message))
    })
  }

  if (6905 %in% indicator_ids) {
    cat("ID 6905 wird berechnet")
    tryCatch({
      source("functions/id_6905.R")
      id_6905(conn, year)
      cat("✅ ID 6905 erfolgreich berechnet.\n")
    }, error = function(e) {
      cat(sprintf("❌ Fehler bei ID 6905: %s\n", e$message))
    })
  }
  
  if (6906 %in% indicator_ids) {
    cat("ID 6906 wird berechnet")
    tryCatch({
      source("functions/id_6906.R")
      id_6906(conn, year)
      cat("✅ ID 6906 erfolgreich berechnet.\n")
    }, error = function(e) {
      cat(sprintf("❌ Fehler bei ID 6906: %s\n", e$message))
    })
  }
  
  if (6909 %in% indicator_ids) {
    cat("ID 6909 wird berechnet")
    tryCatch({
      source("functions/id_6909.R")
      id_6909(conn, year)
      cat("✅ ID 6909 erfolgreich berechnet.\n")
    }, error = function(e) {
      cat(sprintf("❌ Fehler bei ID 6909: %s\n", e$message))
    })
  }
  
  if (6911 %in% indicator_ids) {
    cat("Berechne ID 6911: Quellensteuerertrag\n")
    tryCatch({
      source("functions/id_6911.R")
      id_6911(conn, year)
      cat("✅ ID 6911 erfolgreich berechnet.\n")
    }, error = function(e) {
      cat(sprintf("❌ Fehler bei ID 6911: %s\n", e$message))
    })
  }
  
  if (6912 %in% indicator_ids) {
    cat("Berechne ID 6912: Quellensteuer nach Bezugskategorie\n")
    tryCatch({
      source("functions/id_6912.R")
      id_6912(conn, year)
      cat("✅ ID 6912 erfolgreich berechnet.\n")
    }, error = function(e) {
      cat(sprintf("❌ Fehler bei ID 6912: %s\n", e$message))
    })
  }
  
  if (6980 %in% indicator_ids) {
    cat("Berechne ID 6980: Mittelwert des Gesamtsteuerertrags sowie Anteil von Einkommens- und Vermögenssteuerertrag\n")
    tryCatch({
      source("functions/id_6980.R")
      id_6980(conn, year)
      cat("✅ ID 6980 erfolgreich berechnet.\n")
    }, error = function(e) {
      cat(sprintf("❌ Fehler bei ID 6980: %s\n", e$message))
    })
  }
  
  
  
  # Close the database connection
  close_connection(conn)
  cat("✅ Der Prozess ist abgeschlossen.\n")
}



