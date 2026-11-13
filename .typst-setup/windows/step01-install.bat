@echo off
setlocal DisableDelayedExpansion
call "%~dp0run.bat" "%~dp0..\scripts\install.py"  %*
exit /b %errorlevel%
