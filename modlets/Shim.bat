@echo off

rem Initialization
rem check if we have s_which
echo.Shim
echo.Initializing...
set s_which=false
call s_which s_which.bat
if "[%s_which%]"=="[false]" (
	echo Initialization failed because s_which wasn't found
	pause
	exit 1
)

call s_which nircmd.exe 2>&1 > nul
if not "%_path%" == "" (
	nircmd win setsize ititle MADS_module 680 0 680 340
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
echo.Done

call :run %flag_module%
exit %errorlevel%

:run
set "module=%~n1"
if not exist "%temp%\MADS\cache\built\" (
	mkdir "%temp%\MADS\cache\built\"
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
if not exist "%temp%\MADS\cache\built\%module%.bat" (
	set requiresBuilding=true
) else (
	if defined hash (
		if exist "%temp%\MADS\cache\built\%module%.bat.verified" (
			if exist "%temp%\MADS\cache\built\%module%.bat.shim.verified" (
				for /f usebackq^ skip^=3 %%i in (`%hash% -add %module%.ini -sha1`) do set hashvalue=%%i
				for /F "usebackq delims=" %%i in ("%temp%\MADS\cache\built\%module%.bat.verified") do set verifiedhash=%%i
				if not !hashvalue! == !verifiedhash! (
					set requiresBuilding=true
				) else (
					for /f usebackq^ skip^=3 %%i in (`%hash% -add "%~dpnx0" -sha1`) do set hashvalue2=%%i
					for /F "usebackq delims=" %%i in ("%temp%\MADS\cache\built\%module%.bat.shim.verified") do set verifiedhash2=%%i
					if not !hashvalue2! == !verifiedhash2! (
						set requiresBuilding=true
					)
				)
			)
		) else (
			set requiresBuilding=true
		)
	)
)
if NOT exist %temp%\MADS\cache\built\modulelocation (
	pushd "%~dp1..\"
	echo %CD%>%temp%\MADS\cache\built\modulelocation
	popd
)
endlocal & set requiresBuilding=%requiresBuilding%
if %requiresBuilding% == true (
	echo.Building...
	del /q "%temp%\MADS\cache\built\%module%.bat.verified" >nul 2>&1
	del /q "%temp%\MADS\cache\built\%module%.bat.shim.verified" >nul 2>&1
	@(
	echo/@echo off
	rem echo/REM Requires mod_footer.bat
	echo/setlocal
	echo/set erroct=1
	echo/if exist "%%temp%%\MADS\cache\built\modulelocation" (
	echo/	for /F "usebackq delims=" %%%%a in ("%%temp%%\MADS\cache\built\modulelocation"^) do set modulelocation=%%%%a
	echo/^) else (
	echo/	echo ERROR: Unable to locate module location
	rem TODO: add better error
	echo/	exit 1
	echo/^)
	echo/call mod_header "%%modulelocation%%\%~n1\%~n1.bat" %%*
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
	echo/call mod_footer
	) > "%temp%\MADS\cache\built\%module%.bat"
	echo.Done
)
popd
setlocal enabledelayedexpansion
set requiresTesting=true
REM if not exist "%temp%\MADS\cache\built\%module%.verified" (
	REM set requiresTesting=true
REM ) else (
	REM if defined hash (
		REM if exist "%temp%\MADS\cache\built\%module%.verified" (
			REM for /f usebackq^ skip^=3 %%i in (`%hash% -add %module%.ini -sha1`) do set hashvalue=%%i
			REM for /F "usebackq delims=" %%i in ("%temp%\MADS\cache\built\%module%.verified") do set verifiedhash=%%i
			REM if not !hashvalue! == !verifiedhash! (
				REM set requiresTesting = true
			REM )
		REM ) else (
			REM set requiresTesting = true
		REM )
	REM )
REM )
if %requiresTesting%==true (
	rem check for batch tester
	rem echo.Testing...
	echo.
	cls
	call s_which mod_SelfTest.bat
	if not "[!_path!]" == "[]" (
		call mod_SelfTest "%temp%\MADS\cache\built\%module%.bat"
	) else (
		echo Initialization failed because modSelfTest wasn't found
		pause
		exit 1
	)
	if defined hash (
		for /f usebackq^ skip^=3 %%i in (`%hash% -add %module%.ini -sha1`) do set hashvalue=%%i
		echo !hashvalue!> %temp%\MADS\cache\built\%module%.bat.verified
		for /f usebackq^ skip^=3 %%i in (`%hash% -add "%~dpnx0" -sha1`) do set hashvalue2=%%i
		echo !hashvalue2!> %temp%\MADS\cache\built\%module%.bat.shim.verified
	)
	rem type nul >> %temp%\MADS\cache\built\%module%.verified
	rem echo/>%temp%\MADS\cache\built\%module%.verified
)
if %flag_mode% == run (
	cls
	echo.Shim
	echo.Launching...
	call %temp%\MADS\cache\built\%module%.bat
)
endlocal & exit %errorlevel%