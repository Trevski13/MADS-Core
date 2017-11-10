@echo off
rem This script parses "flags"
rem Basically everytime you indicate a flag e.g. "/flagname" or "-flagname" followed by a value it sets flag_flagname to the value(s) after it
rem By default " (double quotes) are removed from the values; however, if you would like to include them (or a value that starts with "/" or "-"), you can use the ":" syntax to declare it
rem The ":" syntax is uesd by putting ":" after the flag and then the value e.g. "/flagname:value" 
rem Note that all " (double quotes) will be kept in all values after the ":" until a new flag is declared
rem If the flag doesn't have anything after it or has another flag, the script looks if the second character of that flag was "-" e.g. "/-flagname" or "--flagname"
rem it then sets flag_flagname to "true" or "false" if it lacks or contains "-" respectively
rem Values input without an explicit flag are implicitly added to flag_default, so be aware that it's value will become "true" if the first argument is a flag
if "[%debug%]"=="[true]" echo DEBUG: Begin flag_parsing
rem Clear Old Flags
for /f "usebackq delims==" %%i IN (`set ^| findstr /i /c:"flag_"`) do (
	if "[%debug%]"=="[true]" echo DEBUG: clearing %%i
	set "%%i="
)
set "currentflag=default"
set "flag_default="
set "raw=false"
:top
set "flag=false"
rem set the option to the current value, note that we remove surrounding "s here via "%%~" note that is actually a single percent but I have to put two to no break
set "option=%1"
rem check if any peramiters are left
if not defined option goto empty
set "option=%~1"
if "[%debug%]"=="[true]" echo DEBUG: Analysing input %~1
rem check if flag based on "/" as first character
if "[%option:~0,1%]"=="[/]" (
	if "[%debug%]"=="[true]" echo DEBUG: is /flag
	set "flag=true"
)
rem check if flag based on "-" as first character
if "[%option:~0,1%]"=="[-]" (
	if "[%debug%]"=="[true]" echo DEBUG: is -flag
	set "flag=true"
)
if "[%debug%]"=="[true]" echo DEBUG: Flag Check Complete
rem check if we need to implement "raw" mode (this allows us to pass items keeping " as needed)
if %flag%==false (
	if %raw%==true (
		rem so this is a cool little trick, I set the variable workaround to "option=%%1" (the double %% becomes a single %% when parsed)
		rem then in the call statement it becomes: call set %workaround% which becomes: set option=%%1, which becomes: set option=whatever %%1 equals
		rem without the call statement this line could break even if it isn't run due to batch's handling of "(" and ")" in if statements
		set workaround="option=%%1"
		call set %%workaround%%
	)
)

if "[%debug%]"=="[true]" echo DEBUG: Begin Parsing

if %flag%==false (
	rem check if there's anything currently assigned to the current flag
	if not defined flag_%currentflag% (
		rem there isn't, so we'll just set it to the current value
		if "[%debug%]"=="[true]" echo DEBUG: setting flag_%currentflag%
		set "flag_%currentflag%=%option%"
	) else (
		rem there is, so we'll concatinate the old value with the new one
		if "[%debug%]"=="[true]" echo DEBUG: adding to flag_%currentflag%
		rem This call statement allows the "double processing" of the varaibles without using delayed expansion which would require a setlocal statement.
		rem This setlocal, when ended with endlocal, would wipe any variables set by this flag parsing code.
		rem also the echo. is to prevent the selftest from attempting to look up "set" which would fail
		echo. > nul & call set "flag_%currentflag%=%%flag_%currentflag%%% %option%"
	)
	rem we must explicitly shift and goto top here so that the code below isn't processed (even if it isn't run), because it can cause issues with certain values
	shift
	@echo off
	goto top
)
rem else (just to make it look good)
(
	rem the current value is a flag, so we'll check if the previous flag had any values assigned
	if not defined flag_%currentflag% (
			rem it didn't, so we'll check if it was "true" or "false" based on if the second character is a "-"
			if "[%debug%]"=="[true]" echo DEBUG: Previous flag had no value
			if "%currentflag:~0,1%"=="-" (
				rem it is "-", so we'll set the value to "false"
				if "[%debug%]"=="[true]" echo DEBUG: Setting to false
				set "flag_%currentflag:~1%=false"
			) else (
				rem it wasn't "-", so we'll set it to true 
				if "[%debug%]"=="[true]" echo DEBUG: Setting to true
				set "flag_%currentflag%=true"
			)
	)
	rem no we set the currentflag
	if "[%debug%]"=="[true]" echo DEBUG: setting "currentflag"
	rem check to see if the flag has a "raw" mode value assigned to it (indicated via ":")
	echo %option% | findstr /c:":" > nul
	if ERRORLEVEL 1 (
		rem it doesn't so just continue normally
		set raw=false
		if "[%debug%]"=="[true]" echo DEBUG: setting normally
		rem set the flag to the current value, minus the "/" or "-"
		set "currentflag=%option:~1%"
	) else (
		rem it does have a ":"
		set raw=true
		rem handle args set with ":"
		if "[%debug%]"=="[true]" echo DEBUG: setting value before ":"
		rem grab the flag (before the first ":")
		for /f "tokens=1 delims=:" %%i in ('echo %option:~1%') do set "currentflag=%%i"
		rem grab the value (after the first ":")
		for /f "tokens=1,* delims=:" %%i in ('echo %option%') do (
			set withoutquotes=%%j
			rem the below line would have removed quotes from the value, however it was removed to make it possible to pass arguments that had " in them possible
			rem it is left in as an interesting function
			rem echo. > nul & call set withoutquotes=%%withoutquotes:"=%%
			rem the two lines below require call statements to properly process without delayed expansion
			
			rem check if there's anything currently assigned to the current flag
			setlocal enabledelayedexpansion
			if not defined flag_!currentflag! (
				endlocal
				rem there isn't, so we'll just set it to the current value
				if "[%debug%]"=="[true]" call echo DEBUG: setting flag_%%currentflag%% to %%withoutquotes%%
				echo. > nul & call set "flag_%%currentflag%%=%%withoutquotes%%"
			) else (
				endlocal
				rem there is, so we'll concatinate the old value with the new one
				if "[%debug%]"=="[true]" call echo DEBUG: adding %%withoutquotes%% to flag_%%currentflag%%
				echo. > nul & call set "flag_%%currentflag%%=%%flag_%currentflag%%% %%withoutquotes%%"
			)
		)
	)
)
shift
goto top
:empty
rem handle our empty case
if "[%debug%]"=="[true]" echo DEBUG: Empty
rem check for last flag value
if not defined flag_%currentflag% (
		if "[%debug%]"=="[true]" echo DEBUG: Previous flag %currentflag% had no value
		if "%currentflag:~0,1%"=="-" (
			if "[%debug%]"=="[true]" echo DEBUG: Setting to false
			set "flag_%currentflag:~1%=false"
		) else (
			if "[%debug%]"=="[true]" echo DEBUG: Setting to true
			set "flag_%currentflag%=true"
		)
)
rem if debug, list all flags
if "[%debug%]"=="[true]" (
	echo DEBUG: List of Flags:
	for /f "usebackq delims==" %%i IN (`set ^| findstr /i /c:"flag_"`) do (
		echo. > nul & call echo DEBUG: %%i="%%%%i%%"
	)
	echo DEBUG: Done Listing Flags
	pause
)
if "[%debug%]"=="[true]" echo DEBUG: flag_parsing done
:done
exit /b

:perens
rem short function to work around (/) inside "" breaking the script

