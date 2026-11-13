@echo off
setlocal DisableDelayedExpansion
call "%~dp0run.bat" "%~dp0..\scripts\build.py"  %*
exit /b %errorlevel%
