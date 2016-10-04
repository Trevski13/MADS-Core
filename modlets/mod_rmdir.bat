@echo off
setlocal

REM This modlet removes a directory if it isn't already removed

call mod_flag_parsing %*
call mod_help "%~dpnx0" && exit /b

call mod_flag_check /type dir /flag folder
call mod_flag_check /type boolean /flag recurse /defaultValue false

if %flag_recurse%==true (
	set "recurse=/S"
) else (
	set "recurse="
)

call mod_echo "Deleting %flag_folder%..."
call mod_log "Deleting %flag_folder%"
if exist "%flag_folder%" (
	rmdir /q %recurse% "%flag_folder%" 2>&1 >nul
	if exist "%flag_folder%" (
		call mod_tee Error Deleting Folder /color 0C
		set /a errorct+=1
		pause
	) else (
		call mod_tee Removed Sucessfully /color 0A
	)
) else (
	call mod_tee Folder Doesn't Exist, Ignoring /color 0E
)
endlocal
exit /b