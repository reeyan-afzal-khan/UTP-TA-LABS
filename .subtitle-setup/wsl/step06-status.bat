@echo off
python "%~dp0..\scripts\wsl.py" status %*
exit /b %errorlevel%
