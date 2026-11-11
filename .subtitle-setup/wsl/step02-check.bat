@echo off
python "%~dp0..\scripts\wsl.py" check %*
exit /b %errorlevel%
