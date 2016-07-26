@echo off
setlocal
call mod_flag_parsing %*
call mod_flag_check /type string /flag file
call mod_flag_check /type string /flag name /defaultValue
call mod_flag_check /type string /flag args /defaultValue
call mod_flag_check /type boolean /flag wait /defaultValue true

FOR /F "delims=|" %%I IN ('DIR %flag_file% /B /O:D') DO SET NewestFile=%%I
if %debug%==true echo DEBUG: Newest file matching %flag_file% is %NewestFile%

if NOT "[%newestfile%]"=="[]" (
	call mod_run /file %NewestFile% /name %flag_name% /args:%flag_args% /wait %flag_wait%
) else (
	call mod_tee Error: No Matching File Found /color 0C
	set /a errorct+=1
	call mod_pause 
)
endlocal