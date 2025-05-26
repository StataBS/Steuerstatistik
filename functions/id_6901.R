# The function id_6901 calculates the average income per neighborhood and
# the overall average for Basel-Stadt.
#
# param conn A database connection object
# param year Represents the target tax year for which the function will
#        retrieve and process income data.

source("functions/fetch_table_data.R")
source("functions/round_maths.R")

id_6901 <- function(conn, year) {
  # Define required columns from the database
  columns <- c(
    "Reineinkommen",
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
  df_end$Reineinkommen <- as.numeric(df_end$Reineinkommen)
  mean_end_bs <- round_maths(mean(df_end$Reineinkommen, na.rm = TRUE))

  # Filter data for (year - 9)
  df_start <- df[df$Steuerjahr == year - 9, ]
  df_start$Reineinkommen <- as.numeric(df_start$Reineinkommen)
  mean_start_bs <- round_maths(mean(df_start$Reineinkommen, na.rm = TRUE))

  # Average income per residential area
  mean_end_wohnv <- df_end %>%
    group_by(wohnviertel_id_kdm, wohnviertel_name) %>%
    summarise(!!paste0("Mittelwert ", year) := round_maths(mean(Reineinkommen, na.rm = TRUE)), .groups = "drop")

  mean_start_wohnv <- df_start %>%
    group_by(wohnviertel_id_kdm, wohnviertel_name) %>%
    summarise(!!paste0("Mittelwert ", year - 9) := round_maths(mean(Reineinkommen, na.rm = TRUE)), .groups = "drop")

  # Merge results and add Basel-Stadt averages
  df_final <- full_join(mean_start_wohnv, mean_end_wohnv, by = c("wohnviertel_id_kdm", "wohnviertel_name")) %>%
    mutate(
      !!paste0("Mittelwert Basel-Stadt ", year - 9) := mean_start_bs,
      !!paste0("Mittelwert Basel-Stadt ", year) := mean_end_bs
    ) %>%
    arrange(wohnviertel_id_kdm) %>%
    select(
      wohnviertel_name,
      paste0("Mittelwert ", year - 9),
      paste0("Mittelwert Basel-Stadt ", year - 9),
      paste0("Mittelwert ", year),
      paste0("Mittelwert Basel-Stadt ", year)
    ) %>%
    mutate(
      wohnviertel_name = if_else(
        wohnviertel_name == "Altstadt Grossbasel",
        "Altstadt GB",
        wohnviertel_name
      )
    ) %>%
    mutate(
      wohnviertel_name = if_else(
        wohnviertel_name == "Altstadt Kleinbasel",
        "Altstadt KB",
        wohnviertel_name
      )
    ) %>%
    mutate(
      wohnviertel_name = if_else(
        wohnviertel_name == "Kleinhüningen",
        "Kleinhüning.",
        wohnviertel_name
      )
    )

  names(df_final)[names(df_final) == "wohnviertel_name"] <- ""

  # Save result
  jahr <- format(Sys.Date(), "%Y")
  ordner_pfad <- paste0(global_path, jahr, "/")
  if (!dir.exists(ordner_pfad)) {
    dir.create(ordner_pfad, recursive = TRUE)
  }

  datei_pfad <- paste0(ordner_pfad, "6901.tsv")
  write.table(df_final,
    file = datei_pfad, sep = "\t", row.names = FALSE,
    quote = FALSE
  )
}
