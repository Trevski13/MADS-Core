@echo off

REM This modlet installs a program from an MSI file, grabbing the newest file that matches a specified format

setlocal
call mod_flag_parsing %*
call mod_flag_check /type string /flag file
call mod_flag_check /type dir /flag directory /defaultValue .\
call mod_flag_check /type string /flag name
call mod_flag_check /type boolean /flag passive /defaultValue true
call mod_flag_check /type string /flag args /defaultValue:" "

FOR /F "delims=|" %%I IN ('DIR %flag_file% /B /O:D') DO SET NewestFile=%%I
if %debug%==true echo DEBUG: Newest file matching %flag_file% is %NewestFile%

if NOT "[%newestfile%]"=="[]" (
	call mod_msi_install /file %NewestFile% /directory %flag_directory% /name %flag_name% /args %flag_args% /passive %flag_passive%
) else (
	call mod_tee Error: No Matching MSI File Found /color 0C
	set /a errorct+=1
	call mod_pause 
)
endlocal & set errorct=%errorct%
exit /b