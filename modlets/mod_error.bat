@echo off

REM Requires error_codes.txt

REM Description This modlet handles errors and looks up error codes

setlocal enabledelayedexpansion

set speedhack=true
for %%i in (%*) do (
	echo %%i | findstr /b /c:/ /c:- > nul
	if NOT errorlevel 1 (
		set speedhack=false
	)
)

if [%speedhack%]==[false] (
	if "[%debug%]"=="[true]" echo DEBUG: Speedhack Failed... doing this the slow way
	call mod_flag_parsing %*
	call mod_help "%~dpnx0" && exit /b
	call mod_flag_check /type int /flag error
	call mod_flag_check /type string /flag description /defaultValue " " /notes lets you specify a user friendly description of what failed e.g. Copying File
	call mod_flag_check /type boolean /flag silent /defaultValue false
	call mod_flag_check /type boolean /flag lookup /defaultValue true
	call mod_flag_check /type boolean /flag quit /defaultValue false
	call mod_flag_check /type boolean /flag pause /defaultValue true
	call mod_flag_check /type boolean /flag acceptable-error /defaultValue false
	call mod_flag_check /type int /flag alternate-successes /defaultValue 0 /list
	call mod_flag_check /type int /flag alternate-failures /defaultValue 1 /list
) else (
	if "[%debug%]"=="[true]" echo DEBUG: Speedhack Enabled... Fly like the wind
	if "[%1]"=="[/?]" (
		call mod_flag_parsing %*
		call mod_help "%~dpnx0" && exit /b
	)
	set withoutquotes=%1
	echo. > nul & call set withoutquotes=%%withoutquotes:"=%%
	set "flag_error=!withoutquotes!"
	call mod_flag_check /type int /flag error
	set "flag_description= "
	set "flag_silent=false"
	set "flag_lookup=true"
	set "flag_quit=false"
	set "flag_pause=true"
	set "flag_acceptable-error=false"
	set "flag_alternate-successes=0"
	set "flag_alternate-failures=1"
)
rem if "[%pause%]" == "[false]" (
rem 	set flag_pause=false
rem )

set "successes=0"

REM Determine if error
REM Simple Version
if %flag_error%==0 (
	set is_error=false
) else (
	set is_error=true
)

REM Complex Version
echo\%successes%| findstr /r /i /c:"^%flag_error%$" /c:"^%flag_error%," /c:",%flag_error%$" /c:",%flag_error%," > nul 2>&1
if NOT ERRORLEVEL 1 (
	set is_error=false
)
echo\%flag_alternate-successes%| findstr /r /i /c:"^%flag_error%$" /c:"^%flag_error%," /c:",%flag_error%$" /c:",%flag_error%," > nul 2>&1
if NOT ERRORLEVEL 1 (
	set is_error=false
)
echo\%flag_alternate-failures%| findstr /r /i /c:"^%flag_error%$" /c:"^%flag_error%," /c:",%flag_error%$" /c:",%flag_error%," > nul 2>&1
if NOT ERRORLEVEL 1 (
	set is_error=true
)

REM Handle the error
if %is_error%==true (
	if %flag_silent%==false (
		if "[%flag_description%]"=="[ ]" (
			if %flag_acceptable-error%==true (
				call mod_tee /text:ERROR: /text:%flag_error% /color 0E
			) else (
				set /a errorct+=1
				call mod_tee /text:ERROR: /text:%flag_error% /color 0C
			)
		) else (
			if %flag_acceptable-error%==true (
				call mod_tee /text:%flag_description% ERROR: /text:%flag_error% /color 0E
			) else (
				set /a errorct+=1
				call mod_tee /text:%flag_description% ERROR: /text:%flag_error% /color 0C
			)
		)
	) else (
		if "[%flag_description%]"=="[ ]" (
			if %flag_acceptable-error%==true (
				call mod_log /text:ERROR: /text:%flag_error% /color 0E
			) else (
				set /a errorct+=1
				call mod_log /text:ERROR: /text:%flag_error% /color 0C
			)
		) else (
			if %flag_acceptable-error%==true (
				call mod_log /text:%flag_description% ERROR: /text:%flag_error% /color 0E
			) else (
				set /a errorct+=1
				call mod_log /text:%flag_description% ERROR: /text:%flag_error% /color 0C
			)
		)
	)
) else (
	if %flag_silent%==false (
		if "[%flag_description%]"=="[ ]" (
			call mod_tee /text:SUCCESS: /text:%flag_error% /color 0A
		) else (
			call mod_tee /text:%flag_description% SUCESS: /text:%flag_error% /color 0A
		)
	)
)

REM Lookup Error Code
if %flag_lookup%==true (
	call s_which "error_codes.txt"

	if %debug%==true echo DEBUG: Search Results: !_path!
	if NOT "!_path!" == "" (
		set "txtloc=!_path!"
		if %debug%==true echo DEBUG: Found error_codes.txt in path location !_path!
	)
	if exist error_codes.txt (
		set "txtloc=error_codes.txt"
		if %debug%==true echo DEBUG: Found error_codes.txt in the current directory
	)

	if not defined txtloc (
		if %flag_silent%==true (
			call mod_log "error_codes.txt is required for the module and was not found"
			call mod_log "Please include error_codes.txt and try again"
		) else (
			call mod_tee "error_codes.txt is required for the module and was not found" /color 0E
			call mod_tee "Please include error_codes.txt and try again" /color 0E
		)
	)
	for /F "tokens=1,2,3,*" %%i in (!txtloc!) do (
		if "%%j" == "%flag_error%" (
			if %flag_silent%==true (
				call mod_log "Error Code: %%j %%k"
				call mod_log "%%i"
				call mod_log "%%l"

			) else (
				call mod_tee "Error Code: %%j %%k" /color 0B
				call mod_tee "%%i" /color 0B
				call mod_tee "%%l" /color 0B
			)
		)
	)
	if %debug%==true echo DEBUG: Lookup Complete
)
if %is_error%==true (
	if %flag_pause%==true (
		call mod_pause
	)
	if %flag_quit%==true (
		exit %errorct%
	)

)
endlocal & set errorct=%errorct%
exit /b