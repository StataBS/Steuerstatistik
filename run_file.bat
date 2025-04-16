@echo off

REM Set code page to UTF-8 to support special characters
chcp 65001 >nul

REM Ask user for the year to calculate indicators for
set /p year=Für welches Jahr möchtest du die Indikatoren berechnen? 

REM Ask user for the indicator IDs (e.g., c(6901,6902,...))
set /p indicators=Gib die Indikator-IDs ein z.B. c(6901,6902,6903, ...):

REM Step 1: Install/load required R packages
"C:path\to\bin\Rscript.exe" "path\to/functions/bootstrap_packages.R"

REM Step 2: Run main indicator script with year and indicator IDs
"C:/path\to/bin/Rscript.exe" "path\to/start_indikatoren.R"   "%year%" "%indicators%"