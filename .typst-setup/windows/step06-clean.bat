@echo off
setlocal DisableDelayedExpansion
call "%~dp0run.bat" "%~dp0..\scripts\clean.py"  %*
exit /b %errorlevel%
