@echo off
python "%~dp0..\scripts\install.py" %*
exit /b %errorlevel%
