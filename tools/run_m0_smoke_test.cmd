@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_m0_smoke_test.ps1" %*
exit /b %ERRORLEVEL%
