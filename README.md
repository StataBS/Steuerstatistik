# Steuerstatistik Basel-Stadt

Ein vollständiges R-basiertes Auswertungssystem zur automatisierten Berechnung steuerstatistischer Indikatoren sowie zur Durchführung von Plausibilitätsprüfungen für Steuergrundaggregate des Kantons Basel-Stadt.

Das Projekt wurde so aufgebaut, dass es sowohl von fachlichen Anwendern ohne R-Kenntnisse per Batch-Datei als auch von Entwicklern direkt in RStudio genutzt werden kann.

---

## 📌 Projektüberblick

Das System besteht aktuell aus zwei zentralen Modulen.

### 📊 Steuerindikatoren

Automatisierte Berechnung und Export einer Vielzahl steuerstatistischer Indikatoren (`id_XXXX.tsv`).

Die Indikatoren umfassen unter anderem:

- Entwicklung von Steuererträgen
- Einkommens- und Vermögenskennzahlen
- Wohnviertelvergleiche
- Veranlagungsanzahlen
- Klassenverteilungen
- Quellensteuerindikatoren
- langfristige Zeitreihenanalysen

Alle Ergebnisse werden als `.tsv`-Dateien exportiert.

### 🔍 Plausibilisierungsmodul

Automatisierte Erstellung von Excel-Dateien zur fachlichen Plausibilisierung der Steuergrundaggregate:

- Reineinkommen
- Einkommen steuerbar
- Einkommenssteuerbetrag
- Reinvermögen
- Vermögen steuerbar
- Vermögenssteuerbetrag

Das Modul erstellt zwei zentrale Ausgabedateien:

#### Prozentuale Abweichungsanalyse zwischen mehreren Jahren

- automatische Prozentvergleichsblöcke
- farbliche Hervorhebung aller Abweichungen oberhalb einer Toleranzschwelle
- integrierte Konsolenreports über auffällige Veränderungen

#### Grundaggregate je Jahr

- vollständige Tabellenstapel aller verwendeten Jahresgrunddaten
- Einkommen und Vermögen getrennt dargestellt

---

## 📁 Projektstruktur

```text
Steuerstatistik/
│
├── functions/                               # Alle Funktionsdateien
├── Output/                                  # Automatisch erzeugte Ergebnisdateien
├── run_indicators_interactive.R             # Entwickler-Testskript Indikatoren
├── generate_plausibility_interactive.R      # Entwickler-Testskript Plausibilisierung
├── run_indicators.bat                       # Benutzerstart Indikatoren
├── run_plausibility.bat                     # Benutzerstart Plausibilisierung
└── README.md
```

---

## 💾 Ergebnisablage

Alle erzeugten Dateien werden automatisch in einer gemeinsamen Monatsstruktur gespeichert:

```text
Output/YYYY/MM/
```

> Dadurch werden sämtliche Berechnungsläufe chronologisch sauber archiviert.

---

## ▶️ Nutzung des Projekts

### 👤 Nutzung für Fachanwender (ohne RStudio)

Das Projekt kann vollständig über Batch-Dateien per Doppelklick ausgeführt werden.

#### Indikatoren starten

```text
run_indicators.bat
```

Benutzereingaben:

- gewünschtes Steuerjahr
- gewünschte Indikator-ID(s)

Beispiel:

```text
2023
6901,6902,6906
```

#### Plausibilisierung starten

```text
run_plausibility.bat
```

Benutzereingaben:

- mehrere Vergleichsjahre (mindestens zwei)
- Toleranzschwelle in Prozent

Beispiel:

```text
2020,2021,2022
10
```

### 👨‍💻 Nutzung für Entwickler (RStudio / Debugging)

Für Entwickler stehen interaktive Testskripte zur Verfügung.

Diese ermöglichen:

- schnelles Debugging einzelner Module
- direkte Anpassung der Eingabeparameter im Skript
- Ausführung ohne Batch-Datei
- einfachere Fehlersuche in RStudio

## ⚙️ Automatische Rscript-Erkennung

Beide Batch-Dateien wurden so erweitert, dass `Rscript.exe` automatisch gesucht wird.

Dadurch muss der Pfad zu R nicht mehr manuell in der Batch-Datei eingetragen werden.

Zusätzlich wird das Projektverzeichnis automatisch relativ zur Batch-Datei erkannt.

Das bedeutet:

- das Projekt kann an einen beliebigen Speicherort verschoben werden
- die Batch-Dateien bleiben trotzdem lauffähig

---

## 🛠️ Voraussetzungen

Vor der ersten Nutzung müssen folgende Punkte eingerichtet werden.

### 1. R installieren

Benötigt wird eine lokale Installation von:

- R
- Rscript.exe

### 2. Datenbankverbindung konfigurieren

Vor der ersten Nutzung muss die Vorlagedatei angepasst werden:

```text
functions/config.txt
```

Diese Datei muss kopiert oder umbenannt werden zu:

```text
functions/config.R
```

In `config.R` müssen anschliessend die projektspezifischen Einstellungen gepflegt werden, insbesondere:

- `server` = Name oder Adresse des Datenbankservers
- `database` = Name der verwendeten Datenbank

### 3. Erforderliche R-Packages

Die benötigten Pakete werden über `bootstrap_packages.R` automatisch geladen bzw. installiert.

---

## 🧪 Entwicklerhinweise

### Neue Indikatoren hinzufügen

Neue Indikatoren werden als einzelne Dateien im Ordner `functions/` abgelegt:

```text
id_XXXX.R
```

Zusätzlich muss die neue ID in `functions/calculate_indicator.R` in den Vektor `valid_indicator_ids` aufgenommen werden.

Erst danach kann die neue ID über die Batch-Datei oder über `run_indicators_interactive.R` ausgewählt und ausgeführt werden.

---

### 📈 Verfügbare Steuerindikatoren

Aktuell stehen folgende steuerstatistische Indikatoren zur Verfügung:

| ID   | Beschreibung |
|------|--------------|
| 6897 | Entwicklung des Ertrags aus Steuern |
| 6899 | Summe von Reineinkommen, Reinvermögen sowie Einkommen- und Vermögenssteuer (Indexreihe über 10 Jahre) |
| 6900 | Mittelwert und Median des Reineinkommens sowie Summe der Einkommenssteuer (Zeitreihe über 10 Jahre) |
| 6901 | Mittelwert des Reineinkommens nach Wohnviertel (10 Jahres-Vergleich) |
| 6902 | Median des Reineinkommens nach Wohnviertel (10 Jahres-Vergleich) |
| 6903 | Mittelwert und Median des Reinvermögens sowie Summe der Vermögenssteuer (Zeitreihe über 10 Jahre) |
| 6904 | Mittelwert des Reinvermögens nach Wohnviertel (10 Jahres-Vergleich) |
| 6905 | Median des Reinvermögens nach Wohnviertel (10 Jahres-Vergleich) |
| 6906 | Einkommen- und Vermögenssteuer sowie Anzahl Veranlagungen nach Wohnviertel (10 Jahres-Vergleich) |
| 6907 | Einkommenssteuer nach Einkommensklassen |
| 6908 | Vermögenssteuer nach Vermögensklassen |
| 6909 | Gesamtertrag aus Einkommen- und Vermögenssteuer nach Wohnviertel inkl. Vergleich mit Basel-Stadt |
| 6911 | Quellensteuerertrag und Anzahl Veranlagungen nach Wohnviertel (10 Jahres-Vergleich) |
| 6912 | Quellensteuerertrag und Anzahl Veranlagungen nach Bezugskategorie (10 Jahres-Vergleich) |
| 6980 | Gesamtsteuerertrag (Einkommen + Vermögen) pro Wohnviertel |
| 6981 | Ertrag aus Grundstück-, Kapital- und Gewinnsteuern (Zeitreihe über 10 Jahre) |
| 6982 | Gesamtsteuerertrag nach Steuerbetragsklassen |
| 6983 | Gesamtsteuerertrag inkl. satzbestimmendem Gewinn nach Steuerbetragsklassen |

---

## 🌍 Open-Source Nutzung ohne produktive Datenbank

Dieses Repository wurde so aufgebaut, dass der vollständige Projektcode öffentlich bereitgestellt werden kann, ohne Zugriff auf produktive Steuerdaten zu benötigen.

Für Demonstrations-, Test- und Entwicklungszwecke können lokale SQLite-Beispieldatenbanken verwendet werden.

### Enthaltene Beispieldatenbanken

Im Ordner `data/` können folgende SQLite-Dateien abgelegt werden:

```text
data/
├── sas.sqlite
├── sasqst.sqlite
└── JurP.sqlite
```

Diese Datenbanken enthalten ausschliesslich synthetische bzw. fiktive Daten, orientieren sich jedoch an der Struktur der produktiven Umgebung.

Dadurch können:

- Batch-Dateien getestet werden
- Indikatoren berechnet werden
- Plausibilisierungstabellen erzeugt werden
- Entwickler das Projekt lokal ausführen
- externe Nutzer den gesamten Workflow nachvollziehen

### Anpassung von `config.R`

Für die Nutzung der SQLite-Beispieldatenbanken kann `functions/config.R` beispielsweise wie folgt konfiguriert werden:

```r
library(DBI)
library(RSQLite)

global_path <- "Output"

db_mode <- "sqlite"

sqlite_sas <- "data/sas.sqlite"
sqlite_sasqst <- "data/sasqst.sqlite"
sqlite_jurp <- "data/JurP.sqlite"
```

### Anpassung von `db_connection.R`

Die Datenbankverbindung kann anschliessend über SQLite erfolgen:

```r
db_connection <- function() {

  if (db_mode == "sqlite") {

    conn <- DBI::dbConnect(
      RSQLite::SQLite(),
      ":memory:"
    )

    DBI::dbExecute(
      conn,
      sprintf("ATTACH DATABASE '%s' AS sas", sqlite_sas)
    )

    DBI::dbExecute(
      conn,
      sprintf("ATTACH DATABASE '%s' AS sasqst", sqlite_sasqst)
    )

    DBI::dbExecute(
      conn,
      sprintf("ATTACH DATABASE '%s' AS JurP", sqlite_jurp)
    )

    return(conn)
  }

}
```

> Die produktive SQL-Server-Umgebung bleibt dadurch unverändert.  
> Für Open-Source-Nutzung müssen ausschliesslich `config.R` und `db_connection.R` angepasst werden.