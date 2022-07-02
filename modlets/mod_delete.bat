@echo off

REM This modlet deletes a file from a specified location if it exists

call mod_flag_parsing %*
call mod_flag_check /type file /flag file
call mod_flag_check /type string /flag name /defaultValue
call mod_flag_check /type dir /flag directory /defaultValue .\

if NOT "[%flag_name%]"=="[true]" (
	call mod_echo "Deleting %flag_name%..."
	call mod_log "Deleting %flag_name%"
) else (
	call mod_log "Deleting %flag_directory%%flag_file%"
)

if exist "%flag_directory%%flag_file%" 2>nul (
	del /q "%flag_directory%%flag_file%" 2>nul
	if exist "%flag_directory%%flag_file%" 2>nul (
		call mod_tee Error Deleting File /color 0C
		set /a errorct+=1
		call mod_pause
	) else (
		call mod_tee Removed Sucessfully /color 0A
	)
) else (
	call mod_tee File Doesn't Exist, Ignoring /color 0E
)