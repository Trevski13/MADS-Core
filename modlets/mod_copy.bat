@echo off

REM This modlet copies a file from one location to another overwriting it if it exists

call mod_flag_parsing %*
call mod_help "%~dpnx0" && exit /b

call mod_flag_check /type file /flag file
call mod_flag_check /type dir /flag directory /defaultvalue ".\"
call mod_flag_check /type file /flag newname /defaultvalue " "
call mod_flag_check /type dir /flag destination
call mod_flag_check /type string /flag name /defaultvalue
call mod_flag_check /type boolean /flag update /defaultvalue false

if "[%flag_newname%]" == "[ ]" (
	set flag_newname=%flag_file%
)
if "[%flag_directory%]" == "[.\]" (
	set "flag_directory="
)
setlocal enabledelayedexpansion
call s_which fciv.exe
if not "[!_path!]" == "[]" (
	set hash=!_path!
) else (
	set "hash="
)
if "%flag_update%" == "true" (
	if exist "%flag_destination%%flag_newname%" (
		for /f usebackq^ skip^=3 %%i in (`%hash% -add "%flag_destination%%flag_newname%" -sha1`) do set hashvalue1=%%i
		for /f usebackq^ skip^=3 %%i in (`%hash% -add "%flag_directory%%flag_file%" -sha1`) do set hashvalue2=%%i
		if !hashvalue1! == !hashvalue2! (
			call mod_tee File is already up to date, Ignoring... /color 0E
			endlocal
			exit /b
		)
		endlocal
	)
)

if NOT "[%flag_name%]" == "[true]" (
	call mod_echo Copying %flag_name%...
	call mod_log Copying %flag_name% "%flag_directory%%flag_file%" to "%flag_destination%%flag_newname%"
) else (
	call mod_log Copying "%flag_directory%%flag_file%" to "%flag_destination%%flag_newname%"
)
REM TODO: change to xcopy or robocopy
copy  /B /V /Y "%flag_directory%%flag_file%" "%flag_destination%%flag_newname%" 2>&1 >nul
if ERRORLEVEL 1 (
	REM TODO: Implement mod_error
	call mod_tee "error: %errorlevel%" /color 0C
	set /a errorct+=1
	call mod_pause
) else (
	call mod_tee "Copied Sucessfully" /color 0A
)

exit /b