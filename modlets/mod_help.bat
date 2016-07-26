@echo off
setlocal enabledelayedexpansion
set show_help=false
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
	endlocal
	exit /b 1
)
set "string=%~n1"
if exist %1 (
	rem it does, so iterate over all lines that start with "call mod_" and "rem Requires"
	for /F "tokens=1,2*" %%i in ('type %1 ^| findstr /i /c:"call mod_flag_check"') do (
		rem echo %%k
		call mod_flag_parsing %%k
		echo !string! | findstr /i /c:"/!flag_flag!" > nul
		if errorlevel 1 (
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
		)
	)
) else (
	echo Can't find file
	exit /b 0
)

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
if %length% gtr 79 (
	echo !string:~%printfrom%,79!
	set /a printfrom+=79
	set /a length-=79
	set /a end=78-%offset%
	echo.>nul & call :print
) else (
	echo !string!
)

exit /b

:print
if %length% gtr %end% (
	echo !spaces!!string:~%printfrom%,%end%!
	set /a printfrom+=%end%
	set /a length-=%end%
	echo.>nul & call :print
) else (
	echo !spaces!!string:~%printfrom%,%end%!
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