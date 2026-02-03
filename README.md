# Steuerindikatoren Basel-Stadt

Dieses R-Projekt berechnet automatisiert steuerstatistische Indikatoren für den Kanton Basel-Stadt.  
Es nutzt eine ODBC-Datenbankanbindung und ermöglicht sowohl eine einfache Bedienung per Doppelklick (Batch),  
als auch eine flexible Entwickler-Nutzung in RStudio.

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

### 🖱️ Variante A: Für Benutzer (Batch-Modus)

1. Doppelklick auf `run_indicators.bat`
2. Gib das gewünschte Jahr und die ID(s) ein (z.B. `6901,6902`)
3. Die berechneten Dateien findest du unter `output/JJJJ/` als `.tsv`

### 💻 Variante B: Für Entwickler (RStudio)

Benutze das Skript `run_indicators_interactive.R`:

```r
# Beispiel:
year <- 2023
ids <- c(6901, 6902)
```

---

> ℹ️ **Wichtig:**  
> Bevor das Projekt ausgeführt wird, müssen folgende Schritte durchgeführt werden:
>
> 1. **Pfad zu `Rscript.exe` ermitteln**  
>    Öffne die Eingabeaufforderung (CMD) oder PowerShell und führe folgenden Befehl aus:
>    ```
>    where Rscript.exe
>    ```
>    Der angezeigte Pfad wird später im Batch-Skript benötigt.
>
> 2. **Batch-Datei vorbereiten**  
>    - `run_dummy_indicators.text` in `run_indicators.bat` umbenennen  
>    - Den Pfad zu `Rscript.exe` sowie das Projektverzeichnis im Skript korrekt setzen
>
> 3. **Konfigurationsdatei vorbereiten**  
>    - `funktions/dummy_config.text` in `functions/config.R` umbenennen  
>    - Die enthaltenen Verzeichnispfade (`global_path`, `connection_string`) korrekt konfigurieren
>
> Zusätzlich ist sicherzustellen, dass:
> - erforderliche **Proxy-Einstellungen** in den Umgebungsvariablen gesetzt sind  
> - **`Rscript.exe` verwendet wird (nicht `R.exe`)**

---

## 📊 Verfügbare Indikatoren

| ID   | Beschreibung |
|------|--------------|
| 6897 | Entwicklung des Ertrags aus Steuern |
| 6899 | Summe von Reineinkommen, Reinvermögen sowie Einkommen- und Vermögenssteuer (Index, Basisjahr = Jahr − 9) |
| 6900 | Mittelwert und Median des Reineinkommens sowie Summe der Einkommenssteuer (Zeitreihe über 10 Jahre) |
| 6901 | Mittelwert des Reineinkommens nach Wohnviertel (Vergleich Jahr − 9 zu Jahr) |
| 6902 | Median des Reineinkommens nach Wohnviertel (Vergleich Jahr − 9 zu Jahr) |
| 6903 | Mittelwert und Median des Reinvermögens sowie Summe der Vermögenssteuer (Zeitreihe über 10 Jahre) |
| 6904 | Mittelwert des Reinvermögens nach Wohnviertel (Vergleich Jahr − 9 zu Jahr) |
| 6905 | Median des Reinvermögens nach Wohnviertel (Vergleich Jahr − 9 zu Jahr) |
| 6906 | Einkommen- und Vermögenssteuer sowie Anzahl Veranlagungen nach Wohnviertel (Jahr − 9 vs. Jahr) |
| 6907 | Einkommenssteuer nach Einkommensklassen (ein Jahr) |
| 6908 | Vermögenssteuer nach Vermögensklassen (ein Jahr) |
| 6909 | Gesamtertrag aus Einkommen- und Vermögenssteuer nach Wohnviertel inkl. Vergleich mit Basel-Stadt |
| 6911 | Quellensteuerertrag und Anzahl Veranlagungen nach Wohnviertel (Jahr − 9 vs. Jahr) |
| 6912 | Quellensteuerertrag und Anzahl Veranlagungen nach Bezugskategorie (Jahr − 9 vs. Jahr) |
| 6980 | Gesamtsteuerertrag (Einkommen + Vermögen) pro Wohnviertel (ein Jahr) |
| 6981 | Ertrag aus Grundstück-, Kapital- und Gewinnsteuern (Zeitreihe über 10 Jahre) |
| 6982 | Gesamtsteuerertrag nach Steuerbetragsklassen (ein Jahr) |
| 6983 | Gesamtsteuerertrag inkl. satzbestimmendem Gewinn nach Steuerbetragsklassen (ein Jahr) |

---

## 🧠 Hinweise zur Erweiterung

- Neue Indikatoren als `id_xxxx.R` in `functions/` speichern
- Immer `wohnviertel_id_kdm` mitladen (zum Sortieren), aber **nicht exportieren**
- Ergebnis immer als `.tsv` speichern unter `output/<Jahr>/xxxx.tsv`
- Die globale Variable `global_path` definiert, wo TSV-Dateien gespeichert werden  
  `connection_string` ist die ODBC-Verbindungszeichenfolge für den Datenbankzugriff
