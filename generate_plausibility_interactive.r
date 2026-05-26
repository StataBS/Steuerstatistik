# generate_plausibility_interactive.R
# Developer script for manual plausibility testing without batch file

source("functions/config.R")
source("functions/db_connection.R")
source("functions/close_connection.R")
source("functions/bootstrap_packages.R")
source("functions/einkommen_table.R")
source("functions/vermoegen_table.R")
source("functions/report.R")
source("functions/build_plausibility_table_percent_blocks.R")

# ------------------------------------------------------------
# Developer input
# ------------------------------------------------------------

years <- c(2020, 2021)
tolerance_pct <- 10

# ------------------------------------------------------------
# Output paths
# ------------------------------------------------------------

build_output_paths <- function(years, tolerance_pct) {
  current_year <- format(Sys.Date(), "%Y")
  current_month <- format(Sys.Date(), "%m")
  
  output_dir <- file.path(global_path, current_year, current_month)
  
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  list(
    pct = file.path(
      output_dir,
      paste0(
        "Plausibilität_tol_",
        tolerance_pct, "_",
        paste(years, collapse = "_"),
        ".xlsx"
      )
    ),
    tables = file.path(
      output_dir,
      paste0(
        "Grundaggregate_WV_",
        paste(years, collapse = "_"),
        ".xlsx"
      )
    )
  )
}

# ------------------------------------------------------------
# Excel helpers
# ------------------------------------------------------------

add_diff_sheet <- function(wb, sheet, blocks, tolerance_pct) {
  openxlsx::addWorksheet(wb, sheet)
  
  header_style <- openxlsx::createStyle(textDecoration = "bold")
  red_style <- openxlsx::createStyle(fontColour = "#9C0006")
  
  row_pos <- 3
  
  for (nm in names(blocks)) {
    title <- blocks[[nm]]$title
    dat <- blocks[[nm]]$data
    
    openxlsx::writeData(wb, sheet, x = title, startRow = row_pos, startCol = 1)
    row_pos <- row_pos + 1
    
    openxlsx::writeData(wb, sheet, x = dat, startRow = row_pos, startCol = 1, colNames = TRUE)
    openxlsx::addStyle(wb, sheet, header_style, rows = row_pos, cols = 1:ncol(dat), gridExpand = TRUE)
    openxlsx::setColWidths(wb, sheet, cols = 1:ncol(dat), widths = "auto")
    
    data_start_row <- row_pos + 1
    data_start_col <- 2
    data_end_row <- row_pos + nrow(dat)
    data_end_col <- ncol(dat)
    
    if (nrow(dat) > 0 && data_end_col >= data_start_col) {
      m <- as.matrix(dat[, data_start_col:data_end_col, drop = FALSE])
      suppressWarnings(m_num <- apply(m, 2, as.numeric))
      if (!is.matrix(m_num)) m_num <- matrix(m_num, ncol = 1)
      
      idx <- which(!is.na(m_num) & abs(m_num) > tolerance_pct, arr.ind = TRUE)
      
      if (nrow(idx) > 0) {
        rows_excel <- data_start_row + idx[, 1] - 1
        cols_excel <- data_start_col + idx[, 2] - 1
        
        openxlsx::addStyle(
          wb, sheet, red_style,
          rows = rows_excel,
          cols = cols_excel,
          gridExpand = FALSE,
          stack = TRUE
        )
      }
    }
    
    row_pos <- row_pos + nrow(dat) + 3
  }
}

add_year_stack_sheet <- function(wb, sheet, years, conn, table_fun) {
  openxlsx::addWorksheet(wb, sheet)
  
  header_style <- openxlsx::createStyle(textDecoration = "bold")
  row_pos <- 3
  
  for (y in years) {
    dat <- table_fun(conn, y)
    
    openxlsx::writeData(wb, sheet, x = paste0("Jahr ", y), startRow = row_pos, startCol = 1)
    openxlsx::addStyle(wb, sheet, header_style, rows = row_pos, cols = 1, gridExpand = TRUE)
    openxlsx::setColWidths(wb, sheet, cols = 1:ncol(dat), widths = "auto")
    
    row_pos <- row_pos + 1
    
    openxlsx::writeData(wb, sheet, x = dat, startRow = row_pos, startCol = 1, colNames = TRUE)
    openxlsx::addStyle(wb, sheet, header_style, rows = row_pos, cols = 1:ncol(dat), gridExpand = TRUE)
    openxlsx::setColWidths(wb, sheet, cols = 1:ncol(dat), widths = "auto")
    
    row_pos <- row_pos + nrow(dat) + 2
  }
}

# ------------------------------------------------------------
# Main steps
# ------------------------------------------------------------

build_workbook_pct <- function(conn, years, tolerance_pct, datasets) {
  wb <- openxlsx::createWorkbook()
  all_blocks <- list()
  
  for (ds in datasets) {
    sheet <- paste0(ds$key, "_Diff")
    blocks <- build_plausibility_table_percent_blocks(conn, years, ds$fun)
    all_blocks[[ds$key]] <- blocks
    add_diff_sheet(wb, sheet, blocks, tolerance_pct)
  }
  
  list(wb = wb, all_blocks = all_blocks)
}

build_workbook_tables <- function(conn, years) {
  wb <- openxlsx::createWorkbook()
  add_year_stack_sheet(wb, "Einkommen", years, conn, einkommen_table)
  add_year_stack_sheet(wb, "Vermoegen", years, conn, vermoegen_table)
  wb
}

run_reports <- function(all_blocks, tolerance_pct, datasets) {
  for (ds in datasets) {
    report(all_blocks[[ds$key]], tolerance_pct = tolerance_pct)
  }
}

# ------------------------------------------------------------
# RUN interactive
# ------------------------------------------------------------

paths <- build_output_paths(years, tolerance_pct)

datasets <- list(
  list(key = "Einkommen", fun = einkommen_table),
  list(key = "Vermoegen", fun = vermoegen_table)
)

conn <- db_connection()
on.exit(close_connection(conn), add = TRUE)

res_pct <- build_workbook_pct(conn, years, tolerance_pct, datasets)
openxlsx::saveWorkbook(res_pct$wb, paths$pct, overwrite = TRUE)
cat("✅ Datei 1 erstellt: ", paths$pct, "\n")

wb_tables <- build_workbook_tables(conn, years)
openxlsx::saveWorkbook(wb_tables, paths$tables, overwrite = TRUE)
cat("✅ Datei 2 erstellt: ", paths$tables, "\n\n")

run_reports(res_pct$all_blocks, tolerance_pct, datasets)