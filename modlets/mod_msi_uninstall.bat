@echo off
setlocal enabledelayedexpansion

REM Uninstalls an msi file or GUID

call mod_flag_parsing %*
call mod_help "%~dpnx0" && exit /b

call mod_flag_check /type string /flag file /notes can take either a file or a GUID in the form {GUID}
call mod_flag_check /type string /flag name /defaultValue
call mod_flag_check /type boolean /flag passive /defaultValue true
call mod_flag_check /type string /flag args /defaultValue " "

if "[%flag_passive%]"=="[true]" (
	set "passive=/passive"
) else (
	set "passive="
)
if NOT "[%flag_name%]"=="[true]" (
	call mod_echo "Uninstalling %flag_name%..."
	call mod_log "Uninstalling %flag_name% via %flag_file%"
) else (
	call mod_log "Uninstalling %flag_file%"
)
start "" /wait msiexec /x "%flag_file%" %passive% %flag_args%
call mod_error /error %errorlevel% /alternate-successes "3010,1605"
endlocal & set errorct=%errorct%
exit /b