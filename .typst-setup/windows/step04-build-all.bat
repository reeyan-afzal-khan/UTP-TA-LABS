@echo off
setlocal
where python >nul 2>nul
if errorlevel 1 (echo Install Python 3.12 or newer and add it to PATH. & exit /b 1)
python "%~dp0..\scripts\build.py" --all %*
exit /b %errorlevel%
