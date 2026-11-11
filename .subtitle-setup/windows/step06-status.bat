@echo off
"%~dp0..\.venv\Scripts\python.exe" -u "%~dp0..\scripts\manage.py" status %*
exit /b %errorlevel%
