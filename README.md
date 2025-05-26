# Steuerindikatoren Basel-Stadt

Dieses R-Projekt berechnet automatisiert steuerstatistische Indikatoren für den Kanton Basel-Stadt.  
Es nutzt eine ODBC-Datenbankanbindung und ermöglicht sowohl eine einfache Bedienung per Doppelklick (Batch),  
als auch eine flexible Entwickler-Nutzung in RStudio.

---

---

## 📁 Verzeichnisstruktur

```
projekt/
├── functions/                          # Alle Indikatorfunktionen (id_6901.R, id_6902.R, ...)
├── calculate_indicator.R               # Hauptlogik für Batch & Dev
├── run_indicators.bat                  # Start-Skript für nicht-technische Benutzer
├── run_indicators_interactive.R        # Entwickler-Modus (direkt in RStudio)
├── output/                             # Ordner mit TSV-Ausgaben
└── README.md
```

---

## ▶️ Nutzung

### 🖱️ **Variante A: Für Benutzer (Batch-Modus)**

1. Doppelklick auf `run_indicators.bat`
2. Gib das gewünschte Jahr und die ID(s) ein (z.B. `6901,6902`)
3. Die berechneten Dateien findest du unter `output/JJJJ/` als `.tsv`

### 💻 **Variante B: Für Entwickler (RStudio)**

Benutze das Skript `run_indicators_interactive.R`:

```r
# Beispiel:
year <- 2023
ids <- c(6901, 6902)
```

---

> ℹ️ **Wichtig:**  
> Bitte vor der Nutzung folgende Dateien anpassen:  
> 
> - `run_dummy_indicators.bat` → umbenennen zu `run_indicators.bat` und Pfade im Skript anpassen  
> - `dummy_config.R` → umbenennen zu `config.R` und darin enthaltene Verzeichnispfade korrekt setzen

---

## 📊 Verfügbare Indikatoren

| ID     | Beschreibung                                             |
|--------|----------------------------------------------------------|
| 6900   | Gesamtertrag Einkommensteuer kantonsweit (über Zeit)     |
| 6901   | Durchschnittliches Reineinkommen pro Wohnviertel         |
| 6902   | Median Reineinkommen pro Wohnviertel                     |
| 6904   | Durchschnittliches Reinvermögen                          |
| 6905   | Median Reinvermögen                                      |
| 6906   | Einkommen/Vermögensteuer & Veranlagungszahlen            |
| 6909   | Gesamtertrag Eink.+Vermögen + Vergleich mit Kanton       |
| 6911   | Quellensteuerertrag pro Wohnviertel                      |
| 6912   | Quellensteuer nach Bezugskategorie                       |
| 6899   | Indexierte Entwicklung (Veranlagung, Einkommen, Vermögen)|
| 6980   | Steuerertrag pro Wohnviertel (einzelnes Jahr)            |

---

## 🧠 Hinweise zur Erweiterung

- Neue Indikatoren als `id_xxxx.R` in `functions/` speichern
- Immer `wohnviertel_id_kdm` mitladen (zum Sortieren), aber **nicht exportieren**
- Ergebnis immer als `.tsv` speichern unter `output/<Jahr>/xxxx.tsv`
- Die globale Variable `global_path` definiert, wo TSV-Dateien gespeichert werden. `connection_string` ist ODBC-Verbindungszeichenfolge für den Datenbankzugriff

