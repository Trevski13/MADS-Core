@echo off
setlocal enabledelayedexpansion
call mod_flag_parsing %*
call mod_flag_check /type string /flag guid
call mod_flag_check /type string /flag name /defaultValue
call mod_flag_check /type boolean /flag passive /defaultValue true
call mod_flag_check /type string /flag args /defaultValue " "

if %flag_passive%==true (
	set "passive=/passive"
) else (
	set "passive="
)
if NOT %flag_name%==true (
	call mod_echo "Uninstalling %flag_name%..."
	call mod_log "Uninstalling %flag_name% via %flag_guid%"
) else (
	call mod_log "Uninstalling GUID %flag_guid%"
)
start "" /wait msiexec /x %flag_guid% %passive% %flag_args%
if ERRORLEVEL 1 (
	if %errorlevel% NEQ 3010 (
		if %errorlevel% NEQ 1605 (
			call mod_tee  Error: %errorlevel% /color 0C
			call mod_msi_error_lookup %errorlevel%
			set /a errorct+=1
			call mod_pause
		) else (
			call mod_tee  Error: %errorlevel% /color 0E
			call mod_msi_error_lookup %errorlevel%
		)
	) else (
		call mod_msi_error_lookup %errorlevel%
		call mod_tee Done /color 0A
	)
) else (
	call mod_msi_error_lookup %errorlevel%
	call mod_tee Done /color 0A
)
endlocal