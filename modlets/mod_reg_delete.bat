@echo off

REM This modlet deletes a registry entry to a specified location

call mod_flag_parsing %*
call mod_flag_check /type regdir /flag path
call mod_flag_check /type string /flag name /defaultValue "[Default]" /notes when not specified, will delete the whole tree

if "%flag_name%" == "[Default]" (
	call mod_tee Removing %flag_path%
) else (
	call mod_tee Removing %flag_name% from %flag_path%
)
if "%flag_name%" == "[Default]" (
	reg query "%flag_path%" >nul 2>&1 
) else (
	reg query "%flag_path%" /v "%flag_name%" >nul 2>&1
)
if ERRORLEVEL 1 (
	call mod_tee Key Doesn't Exist, Ignoring /color 0E
	exit /b 0
)

if "%flag_name%" == "[Default]" (
	reg delete "%flag_path%" /f >nul
) else (
	reg delete "%flag_path%" /f /v "%flag_name%" >nul
)
if ERRORLEVEL 1 (
	call mod_error /error %errorlevel% /pause false
)
if "%flag_name%" == "[Default]" (
	reg query "%flag_path%" >nul 2>&1
) else (
	reg query "%flag_path%" /v "%flag_name%" >nul 2>&1
)
if ERRORLEVEL 1 (
	call mod_tee Key Removed /color 0A
) else (
	call mod_error /error %errorlevel% /lookup false /description Deleting Reg Key /alternative-success 1 /alternative-failure 0
)
exit /b