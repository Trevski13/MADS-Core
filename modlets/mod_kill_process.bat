@echo off

REM This modlet kills a running process, forcefully if necessary

call mod_flag_parsing %*
call mod_help "%~dpnx0" && exit /b
call mod_flag_check /type file /flag process


call mod_echo Closing %flag_process%...
call mod_log Closing %flag_process%
tasklist /FI "IMAGENAME eq %flag_process%" 2>NUL | find /I /N "%flag_process%">NUL
if NOT ERRORLEVEL 1 (
	Taskkill /IM "%flag_process%"
	timeout /nobreak 2 > nul
	tasklist /FI "IMAGENAME eq %flag_process%" 2>NUL | find /I /N "%flag_process%">NUL
	if NOT ERRORLEVEL 1 (
		call mod_echo Close Failed, Killing %flag_process%... /color 0E
		call mod_log Close Failed, Killing %flag_process%
		Taskkill /F /IM "%flag_process%"
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