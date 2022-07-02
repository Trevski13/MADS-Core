@echo off
setlocal
set "message=%*"
if NOT defined message (
	if "[%pause%]" == "[false]" (
		timeout 15
	) else (
		pause
	)
	endlocal & exit /b
)
echo %message%
if "[%pause%]" == "[false]" (
	timeout 15 > nul
) else (
	pause > nul
)
endlocal & exit /b
call mod_flag_check /type string /flag test /defaultvalue
