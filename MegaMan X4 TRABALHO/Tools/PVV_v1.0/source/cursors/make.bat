@echo off
call brcc32 cursors.rc
if errorlevel 1 goto error
echo No error.
ren cursors.RES cursors.res /y
goto exit


:error
echo Error!


:exit
pause
