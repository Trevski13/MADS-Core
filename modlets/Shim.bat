@echo off

rem Initialization
rem check if we have s_which
set s_which=false
call s_which s_which.bat
cls
if "[%s_which%]"=="[false]" (
	echo Initialization failed because s_which wasn't found
	pause
	exit 1
)

call s_which mod_flag_parsing.bat
if not "[%_path%]" == "[]" (
	call mod_flag_parsing %*
) else (
	echo Initialization failed because mod_flag_parsing wasn't found
	pause
	exit 1
)

call s_which mod_flag_check.bat
if not "[%_path%]" == "[]" (
	call mod_flag_check /type string /flag module
	call mod_flag_check /type enum /flag mode /acceptedValues cache run /defaultValue run
) else (
	echo Initialization failed because mod_flag_check wasn't found
	pause
	exit 1
)

call s_which fciv.exe
if not "[%_path%]" == "[]" (
	set hash=%_path%
) else (
	set "hash="
)

call :run %flag_module%
exit %errorlevel%

:run
set "module=%~n1"
if not exist "%temp%\MADS\built\" (
	mkdir "%temp%\MADS\built\"
	if ERRORLEVEL 1 (
		echo Unable to create TEMP directory
		pause
		exit 1
	)
)
pushd %~dp1

if not exist "%module%.ini" (
	echo Internal Error: Couldn't find ini file in: %~dp1
	pause
	exit 1
)
setlocal enabledelayedexpansion
set requiresBuilding=false
if not exist "%temp%\MADS\built\%module%.bat" (
	set requiresBuilding=true
) else (
	if defined hash (
		if exist "%temp%\MADS\built\%module%.verified" (
			for /f usebackq^ skip^=3 %%i in (`%hash% -add %module%.ini -sha1`) do set hashvalue=%%i
			for /F "usebackq delims=" %%i in ("%temp%\MADS\built\%module%.verified") do set verifiedhash=%%i
			if not !hashvalue! == !verifiedhash! (
				set requiresBuilding=true
			)
		) else (
			set requiresBuilding=true
		)
	)
)
endlocal & set requiresBuilding=%requiresBuilding%
if %requiresBuilding% == true (
	del /q "%temp%\MADS\built\%module%.verified"
	@(
	echo/@echo off
	echo/setlocal
	echo/set erroct=1
	echo/call mod_header "%~dpn1.bat" %%*
	echo/rem Begin Script
	rem for each line in the file
	@for /F "usebackq delims=" %%a in ("%module%.ini") do @(
		@echo/call mod_%%a
	)
	echo/rem End Script
	echo/setlocal enabledelayedexpansion
	echo/call cmd /q /c mod_footer ^& exit /b %%errorct%%
	echo/endlocal
	echo/echo The Script did not terminate correctly
	echo/pause
	echo/endlocal
	echo/exit /b 1
	) > "%temp%\MADS\built\%module%.bat"
)
popd
setlocal enabledelayedexpansion
set requiresTesting=false
if not exist "%temp%\MADS\built\%module%.verified" (
	set requiresTesting=true
) else (
	if defined hash (
		if exist "%temp%\MADS\built\%module%.verified" (
			for /f usebackq^ skip^=3 %%i in (`%hash% -add %module%.ini -sha1`) do set hashvalue=%%i
			for /F "usebackq delims=" %%i in ("%temp%\MADS\built\%module%.verified") do set verifiedhash=%%i
			if not !hashvalue! == !verifiedhash! (
				set requiresTesting = true
			)
		) else (
			set requiresTesting = true
		)
	)
)
if %requiresTesting%==true (
	rem check for batch tester
	call s_which mod_SelfTest.bat
	if not "[!_path!]" == "[]" (
		call mod_SelfTest "%temp%\MADS\built\%module%.bat"
	) else (
		echo Initialization failed because modSelfTest wasn't found
		pause
		exit 1
	)
	if defined hash (
	for /f usebackq^ skip^=3 %%i in (`%hash% -add %module%.ini -sha1`) do set hashvalue=%%i
	echo !hashvalue!> %temp%\MADS\built\%module%.verified
	)
	rem type nul >> %temp%\MADS\built\%module%.verified
	rem echo/>%temp%\MADS\built\%module%.verified
)
if %flag_mode% == run (
	call %temp%\MADS\built\%module%.bat
)
endlocal & exit %errorlevel%