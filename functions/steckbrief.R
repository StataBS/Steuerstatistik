library(openxlsx)

steckbrief <- function(titel, infos_col4, auskuenfte, dateiname) {
  
  # Neues Workbook und Arbeitsblatt
  wb <- createWorkbook()
  addWorksheet(wb, "Steckbrief")
  
  # Rasterlinien ausblenden
  showGridLines(wb, "Steckbrief", showGridLines = FALSE)
  
  # Spaltenbreiten A–D anpassen (A ist extra breit)
  setColWidths(wb, "Steckbrief", cols = 1:4, widths = c(6.11, 23.56, 0.81, 65.22))
  
  # Zeilenhöhe von 1-4 anpassen
  setRowHeights(wb, "Steckbrief", rows = 1:4, height = c(33, 16.5, 6.8, 16.5))
  
  # ---------------- STYLES ----------------
  bold <- function(size = 10, font = "Arial") {
    createStyle(fontName = font, fontSize = size, textDecoration = "bold")
  }
  normal <- function(size = 10, font = "Arial") {
    createStyle(fontName = font, fontSize = size)
  }
  underline_R <- createStyle(fontName = "Arial", fontSize = 10, border = "bottom", halign = "right") # Style mit Rechtsausrichtung
  black_fill <- createStyle(fgFill = "#000000")  # schwarze Zelle
  
  # ---------------- HEADER ----------------
  
  writeData(wb, "Steckbrief", "Präsidialdepartement des Kantons Basel-Stadt", startCol = 2, startRow = 1)
  addStyle(wb, "Steckbrief", normal(8), rows = 1, cols = 2)
  
  writeData(wb, "Steckbrief", "Statistisches Amt", startCol = 2, startRow = 2)
  addStyle(wb, "Steckbrief", bold(11), rows = 2, cols = 2)
  
  writeData(wb, "Steckbrief", titel[1], startCol = 2, startRow = 5)
  addStyle(wb, "Steckbrief", bold(10, "Arial Black"), rows = 5, cols = 2)
  
  writeData(wb, "Steckbrief", titel[2], startCol = 4, startRow = 5)
  addStyle(wb, "Steckbrief", bold(10, "Arial Black"), rows = 5, cols = 4)
  addStyle(wb, "Steckbrief",
           style = createStyle(
             fontName = "Arial Black",
             fontSize = 10,
             textDecoration = "bold",
             halign = "right",
           ), rows = 5, cols = 4
  )
  
  # Zeile 6: schwarze Linie unter t18.2.01
  setRowHeights(wb, "Steckbrief", rows = 6, heights = 2.3)
  addStyle(wb, "Steckbrief", black_fill, rows = 6, cols = 2:4, gridExpand = TRUE)
  
  # Publikationsort
  writeData(wb, "Steckbrief", "Publikationsort:", startCol = 4, startRow = 7)
  addStyle(wb, "Steckbrief", underline_R, rows = 7, cols = 4)
  
  # D8 – Website-Link mit Linie
  writeData(wb, "Steckbrief", "Internetseite des Statistischen Amtes des Kantons Basel-Stadt", startCol = 4, startRow = 8)
  addStyle(wb, "Steckbrief", underline_R, rows = 8, cols = 2:4)
  
  # ---------------- ERLÄUTERUNGEN ----------------
  
  writeData(wb, "Steckbrief", "Erläuterungen:", startCol = 2, startRow = 9)
  addStyle(wb, "Steckbrief", bold(), rows = 9, cols = 2)
  
  labels <- c(
    "Erhebungsart:",
    "Datenquelle:",
    "Referenzperiode:",
    "Verfügbarkeit:",
    "Letzte Aktualisierung:",
    "Nächste Aktualisierung:",
    "Zitiervorschlag [Quelle]:"
  )
  
  setRowHeights(wb, "Steckbrief", rows = 16, heights = 22.5)
  for (i in seq_along(labels)) {
    r <- 9 + i
    writeData(wb, "Steckbrief", labels[i], startCol = 2, startRow = r)
    if (length(infos_col4) >= i) {
      writeData(wb, "Steckbrief", infos_col4[i], startCol = 4, startRow = r)
    }
    addStyle(wb, "Steckbrief", normal(), rows = r, cols = 2)
    addStyle(wb, "Steckbrief", normal(), rows = r, cols = 4)
  }
  
  # Linie unter Zitiervorschlag
  addStyle(wb, "Steckbrief",
           style = createStyle(
             fontName = "Arial",
             fontSize = 10,
             valign = "top",
             border = "bottom" 
           ), rows = 16, cols = 2:4
  )
  
  # ---------------- KONTAKT ----------------
  
  writeData(wb, "Steckbrief", "Weitere Auskünfte:", startCol = 2, startRow = 17)
  addStyle(wb, "Steckbrief", bold(), rows = 17, cols = 2)
  
  auskuenfte <- c(auskuenfte, rep("", 3 - length(auskuenfte)))  # Auffüllen falls weniger als 3
  writeData(wb, "Steckbrief", auskuenfte[1], startCol = 3, startRow = 17)
  writeData(wb, "Steckbrief", auskuenfte[2], startCol = 3, startRow = 18)
  writeData(wb, "Steckbrief", auskuenfte[3], startCol = 3, startRow = 19)
  addStyle(wb, "Steckbrief", normal(), rows = 17:19, cols = 3)
  
  setRowHeights(wb, "Steckbrief", rows = 19, heights = 18.8)
  # Abschlusslinie ganz unten
  addStyle(wb, "Steckbrief",
           style = createStyle(
             fontName = "Arial",
             fontSize = 10,
             valign = "top",
             border = "bottom",
             borderStyle = "medium"
           ), rows = 19, cols = 2:4
  )
  
  insertImage(
    wb,
    sheet = "Steckbrief",
    file = "baselstab.png",  # oder dein PNG
    startRow = 1,
    startCol = 1,
    width = 1.07,
    height = 1.76,
    units = "cm"
  )
  
  # ---------------- SPEICHERN ----------------
  
  saveWorkbook(wb, dateiname, overwrite = TRUE)
}
