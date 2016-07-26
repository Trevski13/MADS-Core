@echo off
setlocal enabledelayedexpansion
call mod_flag_parsing %*
call mod_flag_check /type string /flag file
call mod_flag_check /type string /flag name
call mod_flag_check /type boolean /flag passive /defaultValue true
call mod_flag_check /type string /flag args /defaultValue " "

if "[%debug%]"=="[true]" echo DEBUG: setting Passive Status
if %flag_passive%==true (
	set "passive=/passive"
) else (
	set "passive="
)
if "[%debug%]"=="[true]" echo DEBUG: done Setting Passive Status
call mod_echo Installing %flag_name%...
call mod_log Installing %flag_name% via %flag_file%
if "[%debug%]"=="[true]" echo DEBUG: Installing...
start "" /wait msiexec /i %flag_file% %passive% %flag_args%
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
		call mod_tee Installed /color 0A
	)
) else (
	call mod_msi_error_lookup %errorlevel%
	call mod_tee Installed /color 0A
)
endlocal