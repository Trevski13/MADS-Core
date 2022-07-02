@echo off
setlocal enabledelayedexpansion
if "[%debug%]"=="[true]" echo DEBUG: logging
if not defined scriptName (
	if "[%debug%]"=="[true]" echo DEBUG: scriptName Not defined
	call mod_echo ERROR: Logging Failed /color 0E
	rem call mod_echo /text:---START LOG ENTRY--- /color 0B
	rem call mod_echo %*
	rem call mod_echo /text:----END LOG ENTRY---- /color 0B
	exit /b
)
if not defined logfile (
	if "[%debug%]"=="[true]" echo DEBUG: logfile Not defined
	call mod_echo ERROR: Logging Failed /color 0E
	rem call mod_echo ---START LOG ENTRY--- /color 0B
	rem call mod_echo %*
	rem call mod_echo ----END LOG ENTRY---- /color 0B
	exit /b
)
set speedhack=true
for %%i in (%*) do (
	echo %%i | findstr /b /c:/ /c:- > nul
	if NOT errorlevel 1 (
		set speedhack=false
	)
)
if "[%speedhack%]"=="[false]" (
	if "[%debug%]"=="[true]" echo DEBUG: Speedhack Failed... doing this the slow way
	call mod_flag_parsing %*
	call mod_flag_check /type string /flag text /defaultValue
	if "[!flag_default!]"=="[true]" (
		set "flag_default=!flag_text!"
	)
) else (
	if "[%debug%]"=="[true]" echo DEBUG: Speedhack Enabled... Fly like the wind
	set withoutquotes=%*
	echo. > nul & call set withoutquotes=%%withoutquotes:"=%%
	set "flag_default=!withoutquotes!"
)
echo !scriptName!: !flag_default! >> %logfile%
endlocal
exit/b


setlocal
set withoutquotes=%*
echo. > nul & call set withoutquotes=%%withoutquotes:"=%%
echo %scriptName%: %withoutquotes% >> %logfile%
endlocal
exit /b