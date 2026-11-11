@echo off
python "%~dp0..\scripts\wsl.py" inventory %*
exit /b %errorlevel%
