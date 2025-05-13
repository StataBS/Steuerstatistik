source("functions/steckbrief.R")
source("functions/config.R")
# Define valid indicator IDs
valid_table_ids <- c("t18.2.01")

Webtabellen <- function() {
  # --- Parameter einlesen ---
  if (!exists("input_mode") || input_mode != "interactive") {
    args <- commandArgs(trailingOnly = TRUE)
    tabid <- args[1]
    titel <- args[2]
    # Check if the input is empty
    if (length(tabid) == 0) {
      stop("❌ Fehler: Es wurden keine gültigen IDs eingegeben.")
    }
    
    if (!tabid %in% valid_table_ids) {
      stop(sprintf(
        "❌ Die folgenden ID ist ungültig oder existieret nicht: %s.\n  Bitte gib gültige IDs ein (gültige IDs: %s).",
        paste(valid_table_ids, collapse = ", ")
      ))
    }
    
    infos_col4 <- args[3:9]
      
    # Auskuenfte prüfen: Wenn leer, Standard setzen
    if (args[10] == "") {
      auskuenfte <- c("Ulrich Gräf", "ulrich-maximilian.graef@bs.ch", "061 267 87 79")
    } else {
      auskuenfte <- args[10:12]
    }
  }  
  
  
  # --- Steckbrief erzeugen ---
  dateiname <- paste0(gsub("\\.", "-", tabid), ".xlsx")
  ordner_pfad <- paste0(global_path, dateiname)
  steckbrief(
    titel = c(tabid,titel),
    infos_col4 = infos_col4,
    auskuenfte = auskuenfte,
    dateiname = ordner_pfad
  )
    
  cat(paste0("✅ Steckbrief erfolgreich erstellt: ", dateiname, "\n"))
}

Webtabellen()
