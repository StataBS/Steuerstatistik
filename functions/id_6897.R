# The function id_6897 calculates tax revenues from multiple sources across different views
# and combines them into a single yearly summary table.
#
# param conn A database connection object
# param year The reference tax year (upper limit). All years <= year are included.

source("functions/fetch_table_data.R")
source("functions/round_maths.R")

id_6897 <- function(conn, year) {
  
  # ---------- view: sas ----------
  columns_sas <- c("steuerjahr", "Einkommen_Steuerbetrag_ktgde", "Vermögen_Steuerbetrag_ktgde")
  df_sas <- fetch_table_data(conn, view = "sas", table_name = "veranlagungen_ab_2005_wua", columns = columns_sas)
  df_sas$Einkommen_Steuerbetrag_ktgde <- as.numeric(df_sas$Einkommen_Steuerbetrag_ktgde)
  df_sas$Vermögen_Steuerbetrag_ktgde  <- as.numeric(df_sas$Vermögen_Steuerbetrag_ktgde)
  df_sas_grouped <- df_sas[df_sas$steuerjahr >= year - 9 & df_sas$steuerjahr <= year, ] %>%
    group_by(steuerjahr) %>%
    summarise(
      Einkommenssteuer = round_maths(sum(Einkommen_Steuerbetrag_ktgde, na.rm = TRUE)),
      Vermögenssteuer  = round_maths(sum(Vermögen_Steuerbetrag_ktgde, na.rm = TRUE)),
      .groups = "drop"
    )
  
  # ---------- view: sasqst ----------
  columns_qst <- c("steuerjahr", "steuer_netto")
  df_qst <- fetch_table_data(conn, view = "sasqst", table_name = "quellensteuer_zeitreihe", columns = columns_qst)
  df_qst$steuer_netto <- as.numeric(df_qst$steuer_netto)
  df_qst_grouped <- df_qst[df_qst$steuerjahr >= year - 9 & df_qst$steuerjahr <= year, ] %>%
    group_by(steuerjahr) %>%
    summarise(Quellensteuer = round_maths(sum(steuer_netto, na.rm = TRUE)), .groups = "drop")
  
  # ---------- view: JurP ----------
  columns_jurp <- c("steuerjahr", "gewinn_steuerbetrag_gesamt", "kapital_steuerbetrag_gesamt")
  df_jurp <- fetch_table_data(conn, view = "JurP", table_name = "vVeranlagung", columns = columns_jurp)
  df_jurp$gewinn_steuerbetrag_gesamt  <- as.numeric(df_jurp$gewinn_steuerbetrag_gesamt)
  df_jurp$kapital_steuerbetrag_gesamt <- as.numeric(df_jurp$kapital_steuerbetrag_gesamt)
  df_jurp_grouped <- df_jurp[df_jurp$steuerjahr >= year - 9 & df_jurp$steuerjahr <= year, ] %>%
    group_by(steuerjahr) %>%
    summarise(
      Gewinnsteuer  = round_maths(sum(gewinn_steuerbetrag_gesamt, na.rm = TRUE)),
      Kapitalsteuer = round_maths(sum(kapital_steuerbetrag_gesamt, na.rm = TRUE)),
      .groups = "drop"
    )
  
  # ---------- Merge all ----------
  df_final <- full_join(df_sas_grouped, df_qst_grouped, by = "steuerjahr") %>%
    full_join(df_jurp_grouped, by = "steuerjahr") %>%
    arrange(steuerjahr)
  
  # ---------- Save ----------
  jahr <- format(Sys.Date(), "%Y")
  ordner_pfad <- paste0(global_path, jahr, "/")
  if (!dir.exists(ordner_pfad)) {
    dir.create(ordner_pfad, recursive = TRUE)
  }
  datei_pfad <- paste0(ordner_pfad, "6897.tsv")
  write.table(df_final, file = datei_pfad, sep = "\t", row.names = FALSE, quote = FALSE)
}
