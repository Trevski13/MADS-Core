@echo off

REM This modlet copies a file from one location to another overwriting it if it exists

call mod_flag_parsing %*
call mod_help "%~dpnx0" && exit /b

call mod_flag_check /type file /flag file
call mod_flag_check /type dir /flag directory
call mod_flag_check /type file /flag newname /defaultvalue " "
call mod_flag_check /type dir /flag destination
call mod_flag_check /type string /flag name /defaultvalue

if "[%flag_newname%]" == "[ ]" (
	set flag_newname=%flag_file%
)

if NOT "[%flag_name%]"=="[true]" (
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
	pause
) else (
	call mod_tee "Copied Sucessfully" /color 0A
)

exit /b