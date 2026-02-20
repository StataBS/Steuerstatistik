# The function id_6904 calculates the average net worth per neighborhood and
# the overall average for Basel-Stadt.
#
# param conn A database connection object
# param year Represents the target tax year for which the function will
#        retrieve and process net worth data.

source("functions/fetch_table_data.R")
source("functions/round_maths.R")

id_6904 <- function(conn, year) {
  # Define required columns from the database
  columns <- c(
    "Reinvermögen",
    "wohnviertel_id_kdm",
    "wohnviertel_name",
    "Steuerjahr"
  )

  # Fetch data from the database table
  df <- fetch_table_data(
    conn = conn,
    view = "sas",
    table_name = "veranlagungen_ab_2005_WUA",
    columns = columns
  )

  # Check if the DataFrame is empty
  if (nrow(df) == 0) {
    stop("Error: The DataFrame is empty!")
  }

  # Filter data for the given year
  df_end <- df[df$Steuerjahr == year, ]
  df_end$Reinvermögen <- as.numeric(df_end$Reinvermögen)
  m_end <- round_maths(mean(df_end$Reinvermögen, na.rm = TRUE))

  # Filter data for (year - 9)
  df_start <- df[df$Steuerjahr == year - 9, ]
  df_start$Reinvermögen <- as.numeric(df_start$Reinvermögen)
  m_start <- round_maths(mean(df_start$Reinvermögen, na.rm = TRUE))

  # Calculate average net worth per residential area for each year
  mean_end <- df_end %>%
    group_by(wohnviertel_id_kdm, wohnviertel_name) %>%
    summarise(!!paste0("Mittelwert ", year) := round_maths(mean(Reinvermögen, na.rm = TRUE)), .groups = "drop")

  mean_start <- df_start %>%
    group_by(wohnviertel_id_kdm, wohnviertel_name) %>%
    summarise(!!paste0("Mittelwert ", year - 9) := round_maths(mean(Reinvermögen, na.rm = TRUE)), .groups = "drop")

  # Merge both years and add Basel-Stadt mean
  df_final <- full_join(mean_start, mean_end, by = c(
    "wohnviertel_id_kdm",
    "wohnviertel_name"
  )) %>%
    mutate(
      !!paste0("Mittelwert Basel-Stadt ", year - 9) := m_start,
      !!paste0("Mittelwert Basel-Stadt ", year) := m_end
    ) %>%
    mutate(
      wohnviertel_name = case_when(
        wohnviertel_name == "Altstadt Grossbasel" ~ "Altstadt GB",
        wohnviertel_name == "Altstadt Kleinbasel" ~ "Altstadt KB",
        wohnviertel_name == "Kleinhüningen" ~ "Kleinhüning.",
        TRUE ~ wohnviertel_name
      )
    ) %>%
    arrange(wohnviertel_id_kdm) %>%
    select(
      wohnviertel_name,
      paste0("Mittelwert ", year - 9),
      paste0("Mittelwert Basel-Stadt ", year - 9),
      paste0("Mittelwert ", year),
      paste0("Mittelwert Basel-Stadt ", year)
    )


  names(df_final)[names(df_final) == "wohnviertel_name"] <- ""

  # Save the result
  jahr <- format(Sys.Date(), "%Y")
  ordner_pfad <- file.path(global_path, jahr)
  if (!dir.exists(ordner_pfad)) {
    dir.create(ordner_pfad, recursive = TRUE)
  }
  datei_pfad <- file.path(ordner_pfad, "6904.tsv")
  write.table(df_final,
    file = datei_pfad, sep = "\t", row.names = FALSE,
    quote = FALSE
  )
}
