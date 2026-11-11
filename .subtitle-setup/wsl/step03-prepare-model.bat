@echo off
python "%~dp0..\scripts\wsl.py" download %*
exit /b %errorlevel%
