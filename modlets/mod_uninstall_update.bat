@echo off
setlocal enabledelayedexpansion
call mod_flag_parsing %*
call mod_flag_check /type number /flag kb
call mod_flag_check /type string /flag name /defaultValue
call mod_flag_check /type boolean /flag passive /defaultValue true

if %flag_passive%==true (
	set "passive=/quiet"
) else (
	set "passive="
)
if NOT %flag_name%==true (
	call mod_echo "Uninstalling %flag_name%..."
	call mod_log "Uninstalling %flag_name% via KB%flag_kb%"
) else (
	call mod_tee "Uninstalling KB%flag_kb%"
)
dism /online /get-packages| findstr /C:KB%flag_kb%~
if ERRORLEVEL 1 (
	call mod_tee Update Not installed, Ignoring... /color 0E
	exit /b
)
rem start "" /wait wusa /uninstall /KB:%flag_kb% /norestart %passive%
call mod_error %errorlevel%
endlocal