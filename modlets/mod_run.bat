@echo off
setlocal
echo %1 2>nul | findstr /b /i /c:"/" /c:"-" > nul
if ERRORLEVEL 1 (
	start "" /wait %*
	if ERRORLEVEL 1 (
		if ERRORLEVEL 3010 (
			if ERRORLEVEL 3011 (
				call mod_tee Error: %errorlevel% /color 0C
				set /a errorct+=1
				call mod_pause
			) else (
				call mod_tee Done /color 0A
			)
		) else (
			call mod_tee Error: %errorlevel% /color 0C
			set /a errorct+=1
			call mod_pause
		)
	) else (
		call mod_tee Done /color 0A
	)
	echo. > nul & call endlocal ^& set errorct=%%errorct%%
	exit /b
)
call mod_flag_parsing %*
call mod_flag_check /type file /flag file
call mod_flag_check /type string /flag name /defaultValue
call mod_flag_check /type dir /flag directory /defaultValue .\ /notes if not specified will use the current directory
call mod_flag_check /type string /flag args /defaultValue " "
call mod_flag_check /type boolean /flag wait /defaultValue true
call mod_flag_check /type dir /flag workingdirectory /defaultValue .\ /notes if not specified will use the current directory

if "[%flag_workingdirectory%]"=="[true]" (
	set "flag_workingdirectory=%flag_directory%"
)

if %flag_wait%==true (
	set "wait=/wait"
) else (
	set "wait="
)

if "[%flag_args:~0,1%]"=="[ ]" (
	set "flag_args="
)

if NOT "[%flag_name%]"=="[true]" (
	call mod_echo Running %flag_name%...
	call mod_log Running %flag_name% "%flag_directory%%flag_file%" in directory "%flag_workingdirectory%" with args "%flag_args%"
) else (
	call mod_log Running "%flag_directory%%flag_file%" in directory "%flag_workingdirectory%" with args "%flag_args%"
)



start "" %wait% /d "%flag_workingdirectory%" "%flag_directory%%flag_file%" %flag_args%
call mod_error /error:%errorlevel% /alternate-successes "3010,1605"
REM if ERRORLEVEL 1 (
	REM if %errorlevel% NEQ 3010 (
		REM call mod_tee Error: %errorlevel% /color 0C
		REM set /a errorct+=1
		REM call mod_pause
	REM ) else (
		REM call mod_tee Done /color 0A
	REM )
REM ) else (
	REM call mod_tee Done /color 0A
REM )
endlocal & set errorct=%errorct%
exit /b %errorct%