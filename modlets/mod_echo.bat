@echo off

REM This modlet outputs text to the commandpropmt, adding color if desired

setlocal enabledelayedexpansion
if "[%debug%]"=="[true]" echo DEBUG: Echoing
REM due to the delay in processing flags and the frequency of "echoing" if there's nothing special to be done we won't go through all the steps
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
	call mod_flag_check /type string /flag text /defaultValue
	call mod_flag_check /type string /flag color /defaultValue 07
	if !flag_default!==true (
		set "flag_default=!flag_text!"
	)
) else (
	if "[%debug%]"=="[true]" echo DEBUG: Speedhack Enabled... Fly like the wind
	set withoutquotes=%*
	echo. > nul & call set withoutquotes=%%withoutquotes:"=%%
	set "flag_default=!withoutquotes!"
	echo/!flag_default!
	endlocal
	exit/b
)

REM This is our color hack it's a bit complicated
REM First we change directories to the temp directory
pushd %temp%
REM Next we create a file X that has only a "." in it, we will be looking for this later
<nul > X set /p ".=."
REM Then we capture a "delete" character and save it to DEL
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "DEL=%%a"
REM This line removes "!" from the text
set "param=^%flag_default%" !
REM This line escapes all double quotes
set "param=!param:"=\"!"
REM call findstr on our "file" looking for ".", it will output the name of the "file" (our text) in the color specified as well as "\..\X" at the end
findstr /p /A:%flag_color% "." "!param!\..\X" nul
REM call set /p to output text without creating a newline and overwrite the "\..\X" as well as the carage return and line feed on the previous line
< nul set /p ".=%DEL%%DEL%%DEL%%DEL%%DEL%%DEL%%DEL%"
REM remove our temp file
del /q X 2>&1 >nul
REM put back carage return and line feed
echo.
REM return to our previous directory
popd
endlocal
exit /b