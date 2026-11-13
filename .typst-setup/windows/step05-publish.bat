@echo off
setlocal DisableDelayedExpansion
call "%~dp0run.bat" "%~dp0..\scripts\publish.py"  %*
exit /b %errorlevel%
