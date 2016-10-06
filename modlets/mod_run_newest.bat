@echo off
setlocal enabledelayedexpansion

REM This modlet runs the newest version of a file

call mod_flag_parsing %*
call mod_help "%~dpnx0" && exit /b

call mod_flag_check /type file /flag file
call mod_flag_check /type string /flag name /defaultValue
call mod_flag_check /type dir /flag directory /defaultValue .\
call mod_flag_check /type string /flag args /defaultValue " "
call mod_flag_check /type boolean /flag wait /defaultValue true
call mod_flag_check /type dir /flag workingdirectory /defaultValue

if "[%flag_workingdirectory%]"=="[true]" (
	set "flag_workingdirectory=%flag_directory%"
)

FOR /F "delims=|" %%I IN ('DIR %flag_file% /B /O:D') DO SET NewestFile=%%I
if %debug%==true echo DEBUG: Newest file matching %flag_file% is %NewestFile%

echo.>nul & call :parse %flag_args%

if NOT "[%newestfile%]"=="[]" (
	call mod_run /file %NewestFile% /name %flag_name% %args% /wait %flag_wait%
) else (
	call mod_tee Error: No Matching File Found /color 0C
	set /a errorct+=1
	call mod_pause 
)
endlocal
exit /b

:parse
for /f "tokens=1*" %%a in ("%*") do (
	set arg=%%a
	set is_flag=false
	if "[!arg:~0,1!]" == "[/]" (
		set is_flag=true
	)
	if "[!arg:~0,1!]" == "[-]" (
		set is_flag=true
	)
	if !is_flag!==true (
		if not "[%%a]"=="[]" set "args=!args! /args:%%a"
	) else (
		if not "[%%a]"=="[]" set args=!args! /args "%%a"
	)
    if not "[%%b]"=="[]" call :parse %%b
)
exit /b