@echo off
setlocal enabledelayedexpansion
set show_help=false
set try=1
:check
if "[%flag_?%]"=="[true]" (
	set show_help=true
)
if "[%flag_help%]"=="[true]" (
	set show_help=true
)
if "[%flag_help%]"=="[false]" (
	set show_help=true
)

if %show_help%==false (
	if %try% equ 1 (
		call mod_flag_parsing %*
		set /a try+=1
		goto check
	)
	endlocal
	exit /b 1
)
set notesCount=0
set "string="
if exist %1 (
	rem it does, so iterate over all lines that start with "call mod_" and "rem Requires"
	for /F "tokens=1,2*" %%i in ('type %1 ^| findstr /i /c:"call mod_flag_check"') do (
		rem echo %%k
		call mod_flag_parsing %%k
		echo !string! | findstr /i /c:"/!flag_flag!" > nul
		if errorlevel 1 (
			if "!flag_type!" == "enum" (
				set "flag_type=*See Notes*"
				set notes[!notesCount!]=/!flag_flag! can take any of: !flag_acceptedValues:,=, !
				set /a notesCount+=1
			)
			if "!flag_type!" == "regdir" (
				set notes[!notesCount!]=/!flag_flag! must use short hive name e.g. HKLM not HKEY_LOCAL_MACHINE
				set /a notesCount+=1
			)
			if defined flag_notes (
				set notes[!notesCount!]=/!flag_flag! !flag_notes!
				set /a notesCount+=1
			)
			REM TODO: clean this up, build a string instead of copypasta with edits
			if NOT "!flag_flag!" == "default" (	
				if defined flag_list (
					if defined flag_defaultvalue (
						set "string=!string! [/!flag_flag! {"!flag_type!1,!flag_type!2,..."}]"
					) else (
						set "string=!string! /!flag_flag! {"!flag_type!1,!flag_type!2,..."}"
					)
				) else (
					if defined flag_defaultvalue (
						set "string=!string! [/!flag_flag! !flag_type!]"
					) else (
						set "string=!string! /!flag_flag! !flag_type!"
					)
				)
			) else (
				if defined flag_list (
					if defined flag_defaultvalue (
						set "string= [{"!flag_type!1,!flag_type!2,..."}] !string!"
					) else (
						set "string= {"!flag_type!1,!flag_type!2,..."} !string!"
					)
				) else (
					if defined flag_defaultvalue (
						set "string= [!flag_type!] !string!"
					) else (
						set "string= !flag_type! !string!"
					)
				)

			)
		)
	)
) else (
	echo Can't find file
	exit /b 0
)
rem set description=false
for /F "tokens=1,2*" %%i in ('type %1 ^| findstr /i /b /c:"rem description"') do (
	echo %%k
	rem set description=true
)
REM if !description! == true (
	REM echo\
REM )


set "string=%~n1!string!"
rem echo %string%
rem exit /b 0
set "name=%~n1"
echo.>nul & call :strLen name offset
set printfrom=0

set "spaces= "
for /l %%n in (1,1,%offset%) do (
	set "spaces=!spaces! "
)
echo.>nul & call :strLen string length
echo.
echo USAGE:
set end=79
set newend=%end%
if %length% gtr 79 (
	if NOT "[!string:~%printfrom%,%end%!]" == " " (
		call :breakline
	)
)

if %length% gtr 79 (
	echo !string:~%printfrom%,%newend%!
	set /a printfrom+=%newend%
	set /a length-=%newend%
	set /a newend=%end%
	set /a end=78-%offset%
	echo.>nul & call :print
) else (
	echo !string!
)
if %notesCount% gtr 0 (
	echo\
	echo NOTES:
	for /l %%A in (0,1,%notesCount%) do (
		if %%A neq %notesCount% (
			echo\       !notes[%%A]!
		)
	)
)
exit /b

:print
rem echo %length% gtr %end%
if %length% gtr %end% (
	rem echo "[!string:~%printfrom%,%end%!]"
	REM if NOT "[!string:~%printfrom%,%end%!]" == " " (
		call :breakline
	REM )
)
if %length% gtr %end% (
	echo !spaces!!string:~%printfrom%,%newend%!
	set /a printfrom+=%newend%
	set /a length-=%newend%
	set /a newend=%end%
	rem echo newend: !newend!
	echo.>nul & call :print
) else (
	echo !spaces!!string:~%printfrom%,%end%!
)

exit /b 0

:breakline
set /a printto=%printfrom% + %end%
rem echo breakline called %printfrom% to %printto% where newend: %newend% and end: %end%
(
	for /l %%A in (%printfrom%,1,%printto%) do (
		rem call set stringpart=!string!
		rem echo "[!string:~%%A,1!]"
		if "[!string:~%%A,1!]" == "[ ]" (
			set /a newend=%%A - %printfrom% + 1
			rem echo !newend!
		)
	)
	rem echo %end% became !newend!
)
exit /b 0

:strLen2  strVar  [rtnVar]
setlocal disableDelayedExpansion
set len=0
if defined %~1 for /f "delims=:" %%N in (
  '"(cmd /v:on /c echo(!%~1!&echo()|findstr /o ^^"'
) do set /a "len=%%N-3"
endlocal & if "%~2" neq "" (set %~2=%len%) else echo %len%
exit /b

:strlen <resultVar> <stringVar>
(   
    setlocal EnableDelayedExpansion
    set "s=!%~1!#"
    set "len=0"
    for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
        if "!s:~%%P,1!" NEQ "" ( 
            set /a "len+=%%P"
            set "s=!s:~%%P!"
        )
    )
)
echo off
( 
    endlocal
    set "%~2=%len%"
    exit /b
)
rem call mod_flag_check /type file /flag default
rem call mod_flag_check /type boolean /flag help