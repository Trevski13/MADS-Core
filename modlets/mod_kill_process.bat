@echo off

REM This modlet kills a running process, forcefully if necessary

call mod_flag_parsing %*
call mod_help "%~dpnx0" && exit /b
call mod_flag_check /type file /flag process


call mod_echo Closing %1...
call mod_log Closing %1
tasklist /FI "IMAGENAME eq %~1" 2>NUL | find /I /N "%~1">NUL
if NOT ERRORLEVEL 1 (
	Taskkill /IM %1
	timeout /nobreak 2 > nul
	tasklist /FI "IMAGENAME eq %~1" 2>NUL | find /I /N "%~1">NUL
	if NOT ERRORLEVEL 1 (
		call mod_echo Close Failed, Killing %1... /color 0E
		call mod_log Close Failed, Killing %1
		Taskkill /F /IM %1
		timeout /nobreak 2 > nul
		if NOT ERRORLEVEL 1 (
			call mod_tee Error: Unable to Close or Kill Task /color 0C
			set /a errorct+=1
			pause
		) else (
			call mod_tee Task Killed Sucessfully /color 0A
		)
	) else (
		call mod_tee Task Closed Sucessfully /color 0A
	)
) else (
	call mod_tee Task Not Running, Ignoring /color 0E
)