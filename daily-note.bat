@echo off
echo Ejecutando daily note...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%USERPROFILE%\Scripts\note.ps1" daily

echo.
echo El script termino con codigo: %ERRORLEVEL%
pause