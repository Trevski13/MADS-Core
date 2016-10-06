@echo off

REM This modlet creates a directory if it doesn't exist

call mod_flag_parsing %*
call mod_help "%~dpnx0" && exit /b

call mod_flag_check /type dir /flag directory

call mod_echo Creating Directory %flag_directory%...
call mod_log Creating Directory %flag_directory%
if NOT exist %flag_directory% (
	mkdir %flag_directory% 2>&1 >nul
	if ERRORLEVEL 1 (
		rem TODO: Implement mod_error
		call mod_tee Error: %errorlevel% /color 0C
		set /a errorct+=1
		pause
	) else (
		call mod_tee Directory Created Sucessfully /color 0A
	)
) else (
	call mod_tee Directory Already Exists, Ignoring /color 0E
)