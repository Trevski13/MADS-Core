@echo off

REM Description This script checks that flags have the correct value type
REM Description it is also used by the mod_help modlet to identify proper command line inputs

setlocal enabledelayedexpansion
if "[%debug%]"=="[true]" echo DEBUG: Begin Flag Check
call mod_flag_parsing %*
call mod_help "%~dpnx0" && exit /b
if "[%debug%]"=="[true]" echo DEBUG: Checking Own Flags
rem Check Our Own Flags manually
if NOT defined flag_type ( 
	if "[%debug%]"=="[true]" echo DEBUG: flag "type" not defined.
	echo Runtime Error: Flag parsing check failed.
	if "[%pause%]" == "[false]" (
		timeout 15
	) else (
		pause
	)
	exit 1
) else (
	set typeIsValid=false
	if "%flag_type%"=="boolean" ( set typeIsValid=true )
	if "%flag_type%"=="string" ( set typeIsValid=true )
	rem if "%flag_type%"=="regex" ( set typeIsValid=true )
	if "%flag_type%"=="int" ( set typeIsValid=true )
	if "%flag_type%"=="dir" ( set typeIsValid=true )
	if "%flag_type%"=="file" ( set typeIsValid=true )
	if "%flag_type%"=="enum" ( set typeIsValid=true & set "flag_type=string" )
	if "%flag_type%"=="regdir" ( set typeIsValid=true & set "flag_type=string" )
)
if %typeIsValid%==false (
	if "[%debug%]"=="[true]" echo DEBUG: flag "type" has invalid value "%flag_type%"
	echo Runtime Error: Flag parsing check failed.
	if "[%pause%]" == "[false]" (
		timeout 15
	) else (
		pause
	)
	exit 1
)
if "[%debug%]"=="[true]" echo DEBUG: flag "type" is valid

if not defined flag_flag (
	if "[%debug%]"=="[true]" echo DEBUG: flag "flag" not defined.
	echo Runtime Error: Flag parsing check failed.
	if "[%pause%]" == "[false]" (
		timeout 15
	) else (
		pause
	)
	exit 1
)
if "[%debug%]"=="[true]" echo DEBUG: flag "flag" is valid

endlocal & setlocal enabledelayedexpansion & set "type=%flag_type%" & set "flag=%flag_flag%" & set "defaultValue=%flag_defaultValue%" & set "acceptedValues=%flag_acceptedValues%" & set "list=%flag_list%"

if "[%list%]"=="[true]" (
	echo.>nul & call :parse !flag_%flag%!
	goto :eof
)
goto :valueCheck

:parse
setlocal
set list=%*
if defined list (
	set list=%list:"=%
)
if "[%debug%]"=="[true]" echo DEBUG: list=%list%
FOR /f "tokens=1* delims=," %%a in ("%list%") DO (
	if "[%debug%]"=="[true]" echo DEBUG: first=%%a
	if "[%debug%]"=="[true]" echo DEBUG: rest=%%b
	if not "[%%a]"=="[]" setlocal & set "flag_%flag%=%%a" & call :valueCheck & endlocal
	if not "[%%b]"=="[]" call :parse %%b
)
endlocal
goto :eof

:valueCheck
rem Set Findstr command if acceptedValues is set
if defined acceptedValues (
	rem set "acceptedValuesSearch="
	set "acceptedValuesSearch=/C:%acceptedValues: = /C:%"
	rem for /f %%i in ('echo %acceptedValues%') do call set "acceptedValuesSearch=%%acceptedValuesSearch%%/C:%%i "

)
rem Check Caller Flags
if "[%debug%]"=="[true]" echo DEBUG: Checking flag_%flag% of Input Flag of Type: "%type%"
if "[%debug%]"=="[true]" echo DEBUG: Boolean Check
if "[%type%]"=="[boolean]" (
	if "[%debug%]"=="[true]" echo DEBUG: Checking if Valid boolean
	if defined flag_%flag% (
		set flagvalue=!flag_%flag%!
		if NOT !flagvalue!==true (
			if NOT !flagvalue!==false (
				if "[%debug%]"=="[true]" echo DEBUG: "!flagvalue!" is Not true or false
				echo Runtime Error: Unexpected Flag Value
				echo Enable Debugging for detailed Errors
				if "[%pause%]" == "[false]" (
					timeout 15
				) else (
					pause
				)
				exit 1
			)
		)
	) else (
		if NOT defined defaultValue (
			if "[%debug%]"=="[true]" echo DEBUG: flag_%flag% Not Defined and no Default Value Given
			echo Runtime Error: Unexpected Flag Value
			echo Enable Debugging for detailed Errors
			if "[%pause%]" == "[false]" (
				timeout 15
			) else (
				pause
			)
			exit 1
		) else (
			if "[%debug%]"=="[true]" echo DEBUG: Not Defined, Setting Default Value of "%defaultValue%"
			endlocal & set flag_%flag%=%defaultValue%
			goto :EOF
		)
	)
)
if "[%debug%]"=="[true]" echo DEBUG: String Check
if "[%type%]"=="[string]" (
	if "[%debug%]"=="[true]" echo DEBUG: Checking if valid string
	if NOT defined flag_%flag% (
		if NOT defined defaultValue (
			if "[%debug%]"=="[true]" echo DEBUG: Not Defined and no Default Value Given
			echo Runtime Error: Unexpected Flag Value
			echo Enable Debugging for detailed Errors
			if "[%pause%]" == "[false]" (
				timeout 15
			) else (			
				pause
			)
			exit 1
		) else (
			if "[%debug%]"=="[true]" echo DEBUG: Not Defined, Setting Default Value of "%defaultValue%"
			endlocal & set flag_%flag%=%defaultValue%
			goto :EOF
		)
	)
)
if "[%debug%]"=="[true]" echo DEBUG: Int Check
if "[%type%]"=="[int]" (
	if "[%debug%]"=="[true]" echo DEBUG: Checking if valid int
	if defined flag_%flag% (
		echo !flag_%flag%!| findstr /R /I /C:"^[0123456789]*$" /C:"^-[0123456789]*$" > nul
		if ERRORLEVEL 1 (
			if "[%debug%]"=="[true]" echo DEBUG: "!flag_%flag%!" is not an int
			echo Runtime Error: Unexpected Flag Value
			echo Enable Debugging for detailed Errors
			if "[%pause%]" == "[false]" (
				timeout 15
			) else (
				pause
			)
			exit 1
		)
	) else (
		if NOT defined defaultValue (
			if "[%debug%]"=="[true]" echo DEBUG: Not Defined and no Default Value Given
			echo Runtime Error: Unexpected Flag Value
			echo Enable Debugging for detailed Errors
			if "[%pause%]" == "[false]" (
				timeout 15
			) else (
				pause
			)
			exit 1
		) else (
			if "[%debug%]"=="[true]" echo DEBUG: Not Defined, Setting Default Value of "%defaultValue%"
			endlocal & set flag_%flag%=%defaultValue%
			goto :EOF
		)
	)
)
if "[%debug%]"=="[true]" echo DEBUG: File Check
if "[%type%]"=="[file]" (
	if "[%debug%]"=="[true]" echo DEBUG: Checking if valid file
	if defined flag_%flag% (
		echo !flag_%flag%!| findstr /V /R /I /C:"^.*[<>:/\\|?].*$" /C:"^CON$" /C:"^CON\..*$" /C:"^PRN$" /C:"^PRN\..*$" /C:"^AUX$" /C:"^AUX\..*$" /C:"^NUL$" /C:"^NUL\..*$" /C:"^COM[1-9]$" /C:"^COM[1-9]\..*$" /C:"^LPT[1-9]$" /C:"^LPT[1-9]\..*$" > nul
		if ERRORLEVEL 1 (
			if "[%debug%]"=="[true]" echo DEBUG: "!flag_%flag%!" is not a file
			echo Runtime Error: Unexpected Flag Value
			echo Enable Debugging for detailed Errors
			if "[%pause%]" == "[false]" (
				timeout 15
			) else (
				pause
			)
			exit 1
		)
	) else (
		if NOT defined defaultValue (
			if "[%debug%]"=="[true]" echo DEBUG: Not Defined and no Default Value Given
			echo Runtime Error: Unexpected Flag Value
			echo Enable Debugging for detailed Errors
			if "[%pause%]" == "[false]" (
				timeout 15
			) else (
				pause
			)
			exit 1
		) else (
			if "[%debug%]"=="[true]" echo DEBUG: Not Defined, Setting Default Value of "%defaultValue%"
			endlocal & set flag_%flag%=%defaultValue%
			goto :EOF
		)
	)
)

if "[%debug%]"=="[true]" echo DEBUG: Directory Check
if "[%type%]"=="[dir]" (
	if "[%debug%]"=="[true]" echo DEBUG: Original Directory: !flag_%flag%!
	if not defined flag_%flag% (
		if NOT defined defaultValue (
			if "[%debug%]"=="[true]" echo DEBUG: Not Defined and no Default Value Given
			echo Runtime Error: Unexpected Flag Value
			echo flag_%flag% not defined
			if "[%pause%]" == "[false]" (
				timeout 15
			) else (
				pause
			)
			exit 1
		) else (
			if "[%debug%]"=="[true]" echo DEBUG: Not Defined, setting default: !flag_%flag%!
			set flag_%flag%=%defaultValue%
		)
	)
	if NOT "[!flag_%flag%:~-1!]"=="[\]" (
		if "[%debug%]"=="[true]" echo DEBUG: Adding Trailing Slash
		set flag_%flag%=!flag_%flag%!\
	)
	for %%f in ("!flag_%flag%!") do set flag_%flag%=%%~dpf
	if "[%debug%]"=="[true]" echo DEBUG: Updated Directory: !flag_%flag%!
rem	if "[%debug%]"=="[true]" echo DEBUG: Checking if valid file
rem	if defined flag_%flag% (
rem		echo !flag_%flag%!| findstr /V /R /I /C:"^[a-zA-Z]:\\.*$" > nul
rem	)
)
set fr=!flag_%flag%!
endlocal & set flag_%flag%=%fr%
exit /b

REM call mod_flag_check /flag flag /type string
REM call mod_flag_check /flag type /type enum /acceptedValues "boolean,string,int,dir,file,enum,regdir"
REM call mod_flag_check /flag list /type boolean /defaultValue false
REM call mod_flag_check /flag acceptedValues /type string /list /defaultValue
REM call mod_flag_check /flag defaultValue /type string /defaultValue