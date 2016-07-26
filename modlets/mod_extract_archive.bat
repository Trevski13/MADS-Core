@echo off
rem Requires 7z.exe

call mod_flag_parsing %*
call mod_flag_check /type string /flag file
call mod_flag_check /type string /flag destination /default *

setlocal EnableDelayedExpansion

if exist "%programfiles%\7-zip\7z.exe" (
	set "exeloc=%programfiles%\7-zip\7z.exe"
	if %debug%==true echo DEBUG: Found 7z.exe in Program Files
) else (
	call s_which 7z.exe
	if NOT "!_path!" == "" (
		set "exeloc=7z.exe"
		if %debug%==true echo DEBUG: Found 7z.exe in path location !_path!
	)
	if exist 7z.exe (
		set "exeloc=7z.exe"
			if %debug%==true echo DEBUG: Found 7z.eze in the current directory
	)
)

if not defined exeloc (
	echo Runtime Error: 7-Zip is required for the module and was not found
	echo Please install 7-zip and try again
	pause
	exit 1
)

echo Extracting %flag_file%...
echo %~n0: Extracting %flag_file% to %flag_destination%  >> %temp%\updater.log
"%exeloc%" x "%flag_file%" -o"%flag_destination%" -aoa | findstr /c:"Everything is" /c:"Error: "
if ERRORLEVEL 1 (
	call mod_tee error:  %errorlevel% /color 0C
	set /a errorct+=1
	pause
) else (
	call mod_tee "Extracted Sucessfully" /color 0A
)
endlocal