@echo off
setlocal enabledelayedexpansion
rem Requires runfromprocess-x64.exe
call s_which runfromprocess-x64.exe 2>&1 > nul
if "%_path%" == "" (
	call mod_tee Error: runfromprocess-x64.exe not found /color 0C
	call mod_pause
	exit 1
)
if not defined errorct (
	set errorct=0
)
start "" /min cmd /c timeout /nobreak 3 ^>nul ^& waitfor /s %computername% /si threadingtest
waitfor /t 10 threadingtest > nul
if ERRORLEVEL 1 (
	call mod_tee Error: Interprocess Communication Test Failed /color 0C
	call mod_pause
	exit 1
)

if not exist %temp%\updater\%~n0\test_success (
	call mod_tee Testing Interprocess Communications...
	if not exist %temp%\updater\%~n0\ (
		call mod_make_directory %temp%\updater\%~n0\
		if not %errorct%==!errorct! (
			call mod_tee Error: Interprocess Communication Test Failed /color 0C 
			call mod_pause
			exit 1
		)
	)
	if exist %temp%\updater\%~n0\results (
		call mod_delete /directory %temp%\updater\%~n0\ /file results /name old results file
	)
	echo/0> %temp%\updater\%~n0\results
	set /p result=<%temp%\updater\%~n0\results
	if not !result!==0 (
		call mod_tee Error: Interprocess Communication Test Failed /color 0C 
		call mod_pause
		exit 1
	)

	if exist %temp%\updater\%~n0\results (
		call mod_delete /directory %temp%\updater\%~n0\ /file results /name old results file
	)
	echo/> %temp%\updater\%~n0\test_success
	call mod_tee Interprocess Communications Test Complete
	call mod_newline
)

call mod_flag_parsing %*
call mod_flag_check /type file /flag file
call mod_flag_check /type string /flag name /defaultValue
call mod_flag_check /type dir /flag directory /defaultValue .\
call mod_flag_check /type string /flag args /defaultValue " "
call mod_flag_check /type int /flag waittime /defaultValue " "
call mod_flag_check /type dir /flag workingdirectory /defaultValue true
call mod_flag_check /type boolean /flag cmd /defaultValue false

if "[%flag_workingdirectory%]"=="[true]" (
	set "flag_workingdirectory=%flag_directory%"
)

if NOT "[%flag_name%]"=="[true]" (
	call mod_echo Running %flag_name%...
	call mod_log Running %flag_name% "%flag_directory%%flag_file%" as normal user
) else (
	call mod_log Running "%flag_directory%%flag_file%" as normal user
)

if "[%flag_args:~0,1%]"=="[ ]" (
	set "flag_args="
)

if "[%flag_waittime:~0,1%]"=="[ ]" (
	set "wait="
) else (
	set "wait=/t %flag_waittime%"
)

if %flag_cmd%==true (
	if "%flag_directory%"==".\" (
		set "flag_directory="
	)
)
setlocal disabledelayedexpansion
if %flag_cmd%==true (
	start "" /min runfromprocess-x64.exe explorer.exe cmd.exe /C start "updater_part" cmd.exe /v:on /C cd %flag_workingdirectory% ^^^& "%flag_directory%%flag_file%" %flag_args% ^^^& echo/Return Code: ^^^^^^!errorlevel^^^^^^! ^^^& if errorlevel 1 ^^^( echo/^^^^^^!errorlevel^^^^^^!^^^>%temp%\updater\%~n0\results ^^^& pause ^^^& timeout /nobreak 1 ^^^>nul ^^^& waitfor /s %computername% /si realdeal ^^^) else ^^^( echo/^^^^^^!errorlevel^^^^^^!^^^>%temp%\updater\%~n0\results ^^^& timeout /nobreak 5 ^^^>nul ^^^& waitfor /s %computername% /si realdeal ^^^)
) else (
	start "" /min runfromprocess-x64.exe explorer.exe cmd.exe /C start "" /min cmd.exe /v:on /C start "" /wait /d "%flag_workingdirectory%" "%flag_directory%%flag_file%" %flag_args% ^^^&  if errorlevel 1 ^^^( echo/^^^^^^!errorlevel^^^^^^!^^^>%temp%\updater\%~n0\results ^^^& timeout /nobreak 1 ^^^>nul ^^^& waitfor /s %computername% /si realdeal ^^^) else ^^^( echo/^^^^^^!errorlevel^^^^^^!^^^>%temp%\updater\%~n0\results ^^^& timeout /nobreak 1 ^^^>nul ^^^& waitfor /s %computername% /si realdeal ^^^)
)
endlocal
if ERRORLEVEL 1 (
	call mod_tee Error: Unable to launch process /color 0C
	call mod_pause
	exit 1
)
waitfor %wait% realdeal > nul
if ERRORLEVEL 1 (
	call mod_tee Error: Timeout Reached /color 0C
	call mod_pause
	exit 1
)
if not exist %temp%\updater\%~n0\results (
	call mod_tee Error: Could Not Read Results /color 0C
	call mod_pause
	exit 1
)

set /p result=<%temp%\updater\%~n0\results
if not %result%==0 (
	call mod_tee Error: The running task ended with error %result% /color 0C
	call mod_error %result%
)
call mod_delete /directory %temp%\updater\%~n0\ /file results /name old results file
if %result%==0 (
	call mod_tee Done /color 0A
) else (
	call mod_tee Done /color 0C
)
exit /b %errorct%