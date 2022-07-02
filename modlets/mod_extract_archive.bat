@echo off

REM Requires 7z.exe

REM This modlet extracts a file to a specified directory

call mod_flag_parsing %*
call mod_flag_check /type file /flag file
call mod_flag_check /type dir /flag directory /default .\
call mod_flag_check /type dir /flag destination /default .\
call mod_flag_check /type file /flag newname /default *

setlocal EnableDelayedExpansion

if exist "%programfiles%\7-zip\7z.exe" (
	set "exeloc=%programfiles%\7-zip\7z.exe"
	if "[%debug%]"=="[true]" echo DEBUG: Found 7z.exe in Program Files
) else (
	call s_which 7z.exe
	if NOT "!_path!" == "" (
		set "exeloc=7z.exe"
		if "[%debug%]"=="[true]" echo DEBUG: Found 7z.exe in path location !_path!
	)
	if exist 7z.exe (
		set "exeloc=7z.exe"
			if "[%debug%]"=="[true]" echo DEBUG: Found 7z.eze in the current directory
	)
)

if not defined exeloc (
	echo Runtime Error: 7-Zip is required for the module and was not found
	echo Please install 7-zip and try again
	pause
	exit 1
)

echo Extracting %flag_directory%%flag_file%...
echo %~n0: Extracting %flag_directory%%flag_file% to %flag_destination%%flag_newname%  >> %temp%\updater.log
"%exeloc%" x "%flag_directory%%flag_file%" -o"%flag_destination%%flag_newname%" -aoa | findstr /c:"Everything is" /c:"Error: "
call mod_error /error %errorlevel% /description File Extraction
REM if ERRORLEVEL 1 (
	REM rem call mod_tee error:  %errorlevel% /color 0C
	REM rem set /a errorct+=1
	REM rem pause
REM ) else (
	REM call mod_tee "Extracted Sucessfully" /color 0A
REM )
endlocal & set errorct=%errorct%

exit /b