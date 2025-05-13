# Developer input script: put ID manually
# Sets a key to signal that inputs come from here, not from commandArgs()

# Interactive input

# Please enter the table id (e.g. t18.2.01)
tabid <- "t18.2.01"

# Please enter the title
titel <- "test"

# please enter "Erläuterungen"
infos_col4 <- c(
  "Daten öffentlicher Organe",
  "Steuerverwaltung Basel-Stadt: Steuerregister",
  "Steuerjahr",
  "Seit 2000; jährlich",
  "27. September 2024 (Daten 2021)",
  "Juni 2025",
  "Statistisches Amt des Kantons Basel-Stadt, Steuerstatistik Basel-Stadt"
)
auskuenfte <- c("Ulrich Gräf", "ulrich-maximilian.graef@bs.ch", "061 267 87 79")

# Set a key that calculate_indicator.R can recognize
input_mode <- "interactive"

# Start the main script
source("functions/Webtabellen.R")