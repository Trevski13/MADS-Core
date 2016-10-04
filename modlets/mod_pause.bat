@echo off
setlocal
set "message=%*"
if NOT defined message (
	pause
	endlocal & exit /b
)
echo %message%
pause > nul
endlocal &exit /b