# Developer input script: put year and IDs manually
source("functions/config.R")
source("functions/db_connection.R")
source("functions/close_connection.R")
source("functions/bootstrap_packages.R")

# Please enter the year (e.g. 2023)
year <- 2021 

# Enter the indicator IDs (e.g. 6901,6902,6904)
id <- 6980

# Establish database connection
conn <- db_connection()

fun_name <- paste0("id_", id)

file_path <- paste0("functions/", fun_name, ".R")

source(file_path)

if (exists(fun_name)) {
  get(fun_name)(conn, year)
  cat(sprintf("✅ ID %s erfolgreich berechnet.\n", id))
} else {
  cat(sprintf("❌ Funktion '%s' nicht gefunden.\n", fun_name))
}

# Close the database connection
close_connection(conn)