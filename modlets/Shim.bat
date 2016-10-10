@echo off
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

if not exist "%temp%\MADS\built\%module%.bat" (
	@(
	echo/@echo off
	echo/setlocal
	echo/set erroct=1
	echo/call mod_header %%0 %%*
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
if not exist "%temp%\MADS\built\%module%.verified" (
	rem Initialization
	rem check if we have s_which
	set s_which=false
	call s_which s_which.bat
	cls
	if "[!s_which!]"=="[false]" (
		echo Initialization failed because s_which wasn't found
		pause
		exit 1
	)
	rem check for batch tester
	call s_which mod_SelfTest.bat
	if not "[!_path!]" == "[]" (
		call mod_SelfTest "%temp%\MADS\built\%module%.bat"
	) else (
		echo Initialization failed because modSelfTest wasn't found
		pause
		exit 1
	)
	type nul >> %temp%\MADS\built\%module%.verified
	rem echo/>%temp%\MADS\built\%module%.verified
)

call %temp%\MADS\built\%module%.bat
endlocal & exit %errorlevel%