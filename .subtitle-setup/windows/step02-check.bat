@echo off
if not exist "%~dp0..\.venv\Scripts\python.exe" (
  echo Run step01-install.bat first.
  exit /b 1
)
"%~dp0..\.venv\Scripts\python.exe" -u "%~dp0..\scripts\manage.py" check %*
exit /b %errorlevel%
