@echo off
setlocal enabledelayedexpansion

REM UTF-8 aktivieren
chcp 65001 >nul

REM -------------------------------------------------------
REM Steuerindikatoren – Batch
REM -------------------------------------------------------

REM Projektordner = Ordner, in dem diese Batch-Datei liegt
set "PROJECT_ROOT=%~dp0"
set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"

REM Rscript.exe automatisch finden über Windows Registry
set "RSCRIPT="
set "R_HOME="

for /f "usebackq tokens=2,*" %%A in (`reg query "HKLM\SOFTWARE\R-core\R" /v InstallPath 2^>nul`) do set "R_HOME=%%B"
if not defined R_HOME for /f "usebackq tokens=2,*" %%A in (`reg query "HKLM\SOFTWARE\WOW6432Node\R-core\R" /v InstallPath 2^>nul`) do set "R_HOME=%%B"

if defined R_HOME (
  if exist "%R_HOME%\bin\x64\Rscript.exe" set "RSCRIPT=%R_HOME%\bin\x64\Rscript.exe"
  if not defined RSCRIPT if exist "%R_HOME%\bin\Rscript.exe" set "RSCRIPT=%R_HOME%\bin\Rscript.exe"
)

if not defined RSCRIPT (
  echo Fehler: Rscript.exe wurde nicht gefunden. Bitte R installieren oder Pfad setzen.
  pause
  exit /b 1
)

set "FUNC_DIR=%PROJECT_ROOT%\functions"

:input
cls
echo.
echo ------------------------------------------
echo   Steuerindikatoren berechnen
echo ------------------------------------------
echo.

set "IND_YEARS="
set /p IND_YEARS=Bitte Jahr oder Jahre eingeben (z.B. 2021 oder 2019,2020,2021): 
if "%IND_YEARS%"=="" goto input

set "IND_NO="
set /p IND_NO=Gib die Indikator-IDs ein z.B. c(6901,6902,6903,...) oder 6901,6902: 
if "%IND_NO%"=="" goto input

cd /d "%PROJECT_ROOT%"

REM Leerzeichen entfernen
set "IND_YEARS=%IND_YEARS: =%"

echo.
echo Starte Indikatoren-Berechnung...
echo.

for %%Y in (%IND_YEARS%) do (
    echo ------------------------------------------
    echo Berechne Jahr %%Y
    echo ------------------------------------------
    echo.

    "%RSCRIPT%" "%FUNC_DIR%\calculate_indicator.R" "%%Y" "%IND_NO%"

    if errorlevel 1 (
        echo.
        echo Fehler: Indikatoren-Berechnung fuer Jahr %%Y ist abgebrochen.
        pause
        exit /b 1
    )

    echo.
    echo Jahr %%Y abgeschlossen.
    echo.
)

echo.
echo Alle Indikatoren-Berechnungen abgeschlossen.
pause

endlocal
exit /b 0