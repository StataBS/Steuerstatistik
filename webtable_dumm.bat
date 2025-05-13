@echo off
REM Setze die Codepage auf UTF-8
chcp 65001 >nul

set /p tabid=Bitte gib die Tabellen-ID ein (z.B. t18.2.01): 
set /p titel=Bitte gib den Titel der Webtabelle: 

echo Bitte gib die 7 Werte für Spalte D (Erläuterungen) ein:
set /p d1=1. Erhebungsart: 
set /p d2=2. Datenquelle: 
set /p d3=3. Referenzperiode: 
set /p d4=4. Verfügbarkeit: 
set /p d5=5. Letzte Aktualisierung: 
set /p d6=6. Nächste Aktualisierung: 
set /p d7=7. Zitiervorschlag: 

REM Frage, ob eigene Kontaktdaten eingegeben werden sollen
set /p useContact=Möchtest du eigene Kontaktdaten eingeben? (ja/nein): 

IF /I "%useContact%"=="ja" (
    set /p name=Name für Auskünfte: 
    set /p email=E-Mail: 
    set /p tel=Telefon: 
) ELSE (
    REM Leere Felder – R nutzt Standard
    set name=
    set email=
    set tel=
)

REM Starte R mit allen Parametern
"C:/path\to/bin/Rscript.exe" "path\to/start_indikatoren.R" %tabid% "%d1%" "%d2%" "%d3%" "%d4%" "%d5%" "%d6%" "%d7%" "%name%" "%email%" "%tel%"
pause
