@echo off
setlocal EnableDelayedExpansion

REM This modlet runs a file an waits for it, and it's direct children to exit before returning

call mod_flag_parsing %*
call mod_help "%~dpnx0" && exit /b

call mod_flag_check /type file /flag file
call mod_flag_check /type dir /flag directory /defaultValue:.\
call mod_flag_check /type string /flag name /defaultValue " "
call mod_flag_check /type string /flag args /defaultValue " "
call mod_flag_check /type dir /flag workingdirectory /defaultvalue true
rem call mod_flag_check /type int /flag timeout /defaultValue 10
call mod_flag_check /type int /flag delay /defaultValue 2

if NOT "[%flag_name%]"=="[ ]" (
	call mod_echo Running %flag_name%...
	call mod_log Running %flag_name% "%flag_directory%%flag_file%"
) else (
	call mod_log Running "%flag_directory%%flag_file%"
)
if "[%flag_workingdirectory%]"=="[true]" (
	set "flag_workingdirectory=%flag_directory%"
)
if "[%flag_directory%]"=="[.\]" (
	set flag_directory=%CD%
)
IF %flag_directory:~-1%==\ SET flag_directory=%flag_directory:~0,-1%

pushd "%flag_workingdirectory%" 2>nul
if ERRORLEVEL 1 (
	call mod_tee ERROR: Invalid Directory /color 0C
	set /a errorct+=1
	call mod_pause
	exit 1
)

for /f "tokens=2 delims=;= " %%G IN ('wmic process call create "%flag_file%"^,"%flag_directory%"  ^|find "ProcessId"')  do set /A PID=%%G

if NOT defined PID (
	call mod_tee ERROR: Unable to launch Process /color 0C
	net session >nul 2>&1
    if ERRORLEVEL 1 (
		if exist "%flag_file%" (
			if exist "%flag_directory%" (
				call mod_tee NOTE: This function cannot launch programs that require elevation without being elevated itself /color 0B 
			)
		)
	)
	set /a errorct+=1
	call mod_pause
	exit 1
) else (
	call mod_echo Launched Sucessfully, waiting for exit...
	call mod_log Launched Sucessfully, waiting for exit
)

popd

:pidcheck
timeout /nobreak %flag_delay% > nul
set "ChildPIDs="
for /f "skip=1" %%G IN ('wmic process where ^(parentprocessid^=%pid%^) get ProcessID 2^>nul') do set "ChildPIDs=!ChildPIDs!%%G "
if "[%debug%]"=="[true]" echo DEBUG: PPID: "%PID%"
if "[%debug%]"=="[true]" echo DEBUG: CPIDs: "%ChildPIDs%"
tasklist /FI "PID eq %PID%" 2>NUL | find /i /n "%PID%" > nul
if NOT ERRORLEVEL 1 goto pidcheck
if NOT "[%ChildPIDs%]"=="[ ]" goto pidcheck
rem timeout /nobreak %flag_timeout% > nul
rem tasklist /FI "PID eq %PID%" 2>NUL | find /i /n "%PID%" > nul
rem if NOT ERRORLEVEL 1 goto pidcheck
rem if NOT "[%ChildPIDs%]"=="[ ]" goto pidcheck
call mod_tee Program Exited /color 0A
endlocal
exit/b