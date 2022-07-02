@echo off
setlocal
set debug=false
REM This modlet if something does or doesn't exist and aborts

call mod_flag_parsing %*
call mod_flag_check /type enum /flag mode /acceptedValues "reg,dir"
call mod_flag_check /type boolean /flag AbortOnExist /defaultValue /notes determins if it will abort if the item exists or abort if it doesn't exist
if %flag_mode% == reg (set varies=regdir)
if %flag_mode% == dir (set varies=dir)

call mod_flag_check /type %%varies%% /flag path
call mod_flag_check /type string /flag name /defaultValue "[Default]" /notes when not specified, will look for the whole tree

if %flag_AbortOnExist% == false (set "not= NOT") else (set "not=")
if %flag_AbortOnExist% == false (set "notnot=") else (set "notnot= NOT")
if %flag_mode% == reg (
	call mod_tee Checking Registry...
	if "%flag_name%" == "[Default]" (
		reg query "%flag_path%" >nul 2>&1 
	) else (
		reg query "%flag_path%" /v "%flag_name%" >nul 2>&1
	)
	if%not% ERRORLEVEL 1 (
		call mod_tee "Key Does%notnot% Exist, Proceeding" /color 0A
		exit /b 0
	) else (
		call mod_tee "Key Does%not% Exist, Aborting..." /color 0C
		call mod_pause
		exit 1
	)
)
if %flag_mode% == dir (
	if "%flag_name%" == "[Default]" (
		if%notnot% exist "%flag_path%" (
			call mod_tee "Directory Does%notnot% Exist, Proceeding" /color 0A
			exit /b 0
		) else (
			call mod_tee "Directory Does%not% Exist, Aborting..." /color 0C
			call mod_pause
			exit 1
		)
	) else (
		if%notnot% exist "%flag_path%%flag_name%" (
			call mod_tee "File Does%notnot% Exist, Proceeding" /color 0A
			exit /b 0
		) else (
			call mod_tee "File Does%not% Exist, Aborting..." /color 0C
			call mod_pause
			exit 1
		)
	)
)