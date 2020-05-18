@echo off
call dcc32 -H -M -$M+ -$Q+ -$R+ Yoshitora.dpr
echo.
echo errorlevel: %errorlevel%
pause >nul
