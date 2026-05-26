@echo off
setlocal enabledelayedexpansion
REM Setze die Codepage auf UTF-8
chcp 65001 >nul

REM -------------------------------------------------------
REM Steuer – Zentrales Batch-Menü
REM (Skripte liegen unter: %PROJECT_ROOT%\functions\)
REM -------------------------------------------------------

REM Projektordner = Ordner, in dem diese Batch-Datei liegt
set "PROJECT_ROOT=%~dp0"
set "PROJECT_ROOT=%PROJECT_ROOT:~0,-1%"
REM Rscript.exe automatisch finden (Windows Registry)
set "RSCRIPT="

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

:menu
cls
echo.
echo ==========================================
echo   Hallo!
echo.
echo   Was möchtest du gerne machen?
echo ==========================================
echo.
echo   1) Indikatoren berechnen
echo   2) Plausibilisierungstabellen erstellen
echo.
echo   0) Beenden
echo.
set "CHOICE="
set /p CHOICE=Bitte eine Nummer eingeben und Enter druecken: 

if "%CHOICE%"=="0" goto end
if "%CHOICE%"=="1" goto indicators
if "%CHOICE%"=="2" goto plausi

echo.
echo Ungueltige Eingabe. Bitte waehle eine Zahl zwischen 0 und 2.
pause
goto menu

:indicators
cls
echo.
echo ------------------------------------------
echo   Indikatoren berechnen
echo ------------------------------------------
echo.
set "IND_YEARS="
set /p IND_YEARS=Bitte Jahre eingeben (z.B. 2019,2020,2021): 
if "%IND_YEARS%"=="" goto indicators

set "IND_NO="
set /p IND_NO=Gib die Indikator-IDs ein z.B. c(6901,6902,6903,...): 
if "%IND_NO%"=="" goto indicators

cd /d "%PROJECT_ROOT%"
echo.
echo Starte: functions\calculate_indicator.R "%IND_YEARS%" "%IND_NO%"
echo.
"%RSCRIPT%" "%FUNC_DIR%\calculate_indicator.R" "%IND_YEARS%" "%IND_NO%"

if errorlevel 1 (
    echo.
    echo Fehler: Indikatoren-Berechnung ist mit einem R-Fehler abgebrochen.
    pause
    goto menu
)

echo.
pause
goto menu

:plausi
cls
echo.
echo ------------------------------------------
echo   Plausibilisierungstabellen erstellen
echo ------------------------------------------
echo.
set "PL_YEARS="
set /p PL_YEARS=Bitte Jahre eingeben (z.B. 2019,2020,2021): 
if "%PL_YEARS%"=="" goto plausi

set "PL_TOL="
set /p PL_TOL=Bitte Toleranz in %% eingeben (z.B. 10): 
if "%PL_TOL%"=="" (
  echo.
  echo Fehler: Toleranz darf nicht leer sein.
  pause
  goto plausi
)

cd /d "%PROJECT_ROOT%"
echo.
echo Starte: functions\generate_plausibility.R "%PL_YEARS%" "%PL_TOL%"
echo.
"%RSCRIPT%" "%FUNC_DIR%\generate_plausibility.R" "%PL_YEARS%" "%PL_TOL%"

if errorlevel 1 (
    echo.
    echo Fehler: Plausibilisierung ist mit einem R-Fehler abgebrochen.
    pause
    goto menu
)

echo.
pause
goto menu

:end
echo.
echo Auf Wiedersehen.
endlocal
exit /b 0
