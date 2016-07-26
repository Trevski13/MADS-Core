@echo off
setlocal EnableDelayedExpansion
rem increment the depth counter (aka how manytimes we've called ourselves), as an abnormal increase in this may indicate a dependency loop.
if NOT defined depth (
	set depth=1
) else (
	set /a depth+=1
)
rem check for spinner so we can indicate activity
set spinnerenabled=false
call s_which mod_spinner.bat
if "[%debug%]"=="[true]" echo DEBUG: Path to mod_spinner is "!_path!"
if "!_path!" == "" (
	dir /b %~dp1 | findstr /I /C:"mod_spinner.bat" >nul
	if ERRORLEVEL 1 (
		if "[%debug%]"=="[true]" echo DEBUG: mod_spinner not found
		set spinnerenabled=false
	) else (
		if "[%debug%]"=="[true]" echo DEBUG: mod_spinner found in local directory
		set spinnerenabled=true
	)
) else (
	if "[%debug%]"=="[true]" echo DEBUG: mod_spinner found in path
	set spinnerenabled=true
)
if %depth%==1 (
	echo Executing Self Test...
) else (
	if "[%debug%]"=="[true]" echo DEBUG: Self on "%~1" at level %depth%
)
rem check for "over depth" idealy you shouldn't go over 4 e.g. copy-newest->copy->tee->echo but there's plenty of breathing room if needed
if %depth% geq 10 (
	echo Recusion limit reached, please check scripts for dependency loops
	pause
	exit 1
)
set line=0
rem check to make sure we actually were given an item to check
if "[%1]"=="[]" (
	if "[%debug%]"=="[true]" echo DEBUG: "%%1" is blank
	echo An Error Has Occured while attempting to run the selftest
	echo Please make sure the script is formated properly and run again
	pause
	exit 1
)
rem check that the item actually exists
if exist %1 (
	rem it does, so iterate over all lines that start with "call mod_" and "rem Requires"
	for /F "tokens=*" %%i in ('type %1 ^| findstr /i /c:"call mod_" /c:"rem Requires"') do (
		set /a line+=1
		set /a dospinner=!line! %% 1
		if !dospinner!==0 if %spinnerenabled%==true call mod_spinner /speedhack
		set "item=%%i"
		rem trim whitespace
		for /f "tokens=* delims= " %%a in ("!item!") do set "item=%%a"
		for /l %%a in (1,1,100) do if "!item:~-1!"==" " set "item=!item:~0,-1!"
		rem check for empty
		if NOT "[!item!]" == "[]" (
			rem check for call
			rem if "[%debug%]"=="[true]" echo DEBUG: Checking line "!item!"
			echo/"!item!" 2>&1 | findstr /R /I /C:"^.call .*" 2>&1 > nul
			if NOT ERRORLEVEL 1 (
				if "[%debug%]"=="[true]" echo DEBUG: Line is Call statement
				for /F "tokens=2" %%j IN ('echo "!item! "') do (
					 echo %%j | findstr /i /C:".bat" > nul
					 if ERRORLEVEL 1 (
						call s_which %%j.bat
					 ) else (
						call s_which %%j
					 )
					 if "[%debug%]"=="[true]" echo DEBUG: Path to item is "!_path!"
					 if "!_path!" == "" (
						echo %%j | findstr /i /C:".bat" > nul
						if ERRORLEVEL 1 (
							dir /b %~dp1 | findstr /I /C:"%%j.bat" >nul
						) ELSE (
							dir /b %~dp1 | findstr /I /C:"%%j" >nul
						)
						if ERRORLEVEL 1 (
							if "[%debug%]"=="[true]" echo DEBUG: %%j on line !line! of %~1 doesn't exist
							echo %%j was not found, please check the script for typos
							echo or the components directory for missing components
							pause
							exit 1
						)
					)
					if "[%debug%]"=="[true]" echo DEBUG: Now Checking Flags for %%j
					rem call :flag_check %%j
					REM setlocal enabledelayedexpansion
					REM if exist %1 (
						REM set line=0
						REM for /F "tokens=*" %%i in ('type %1 ^| findstr /i /c:"call mod_flag_check"') do (
							REM set /a line+=1
							REM set /a dospinner=!line! %% 1
							REM if !dospinner!==0 if %spinnerenabled%==true call mod_spinner /speedhack
							REM set "item=%%i"
							REM rem trim whitespace
							REM for /f "tokens=* delims= " %%a in ("!item!") do set "item=%%a"
							REM for /l %%a in (1,1,100) do if "!item:~-1!"==" " set "item=!item:~0,-1!"
							REM rem check for empty
							REM if NOT "[!item!]" == "[]" (
								REM rem check for call
								REM rem if "[%debug%]"=="[true]" echo DEBUG: Checking line "!item!"
								REM echo/"!item!" 2>&1 | findstr /R /I /C:"^.call mod_flag_check .*" 2>&1 > nul
								REM if NOT ERRORLEVEL 1 (
									REM if "[%debug%]"=="[true]" echo DEBUG: Line is Flag Check
									REM set alphabet=abcdefghijklmnopqrstuvwxyz
									REM for /F "tokens=1,2,3,4,5,6,7,8,9,10 delims=/-" %%a IN ('echo "!item! "') do (
										REM for /l %%? in (0,1,25) do (
											REM set letter=!alphabet:~%%?,1!
											REM rem if NOT %%!letter!=="" call echo %%%%!letter!
										REM )
									REM )
								REM )
							REM )
						REM )
					REM ) else (
						REM if "[%debug%]"=="[true]" echo DEBUG: %1 doesn't exist
						REM echo An Error Has Occured while attempting to run the selftest
						REM echo Please make sure the script is formated properly and run again
						REM pause
						REM exit 1
					REM )
					REM endlocal & if %spinnerenabled%==true set "spinner=!spinner!"
					if "[%debug%]"=="[true]" echo DEBUG: Finished Checking Flags for %%j
					echo !checked! | findstr /i /C:"%%j" 2>&1 >nul
					if ERRORLEVEL 1 (
						echo %%j | findstr /i /c:"%~n0" /c:"s_which" 2>&1 >nul
						if ERRORLEVEL 1 (
							if "[%debug%]"=="[true]" echo DEBUG: Now Checking %%j
							if "!_path!" == "" (
								echo %%j | findstr /i /C:".bat" > nul
								if ERRORLEVEL 1 (
									call %~n0 %%j.bat
								) ELSE (
									call %~n0 %%j
								)
							) else (
								call %~n0 !_path!
							)
							if "[%debug%]"=="[true]" echo DEBUG: Finished Checking %%j
						)
					) else (
						if "[%debug%]"=="[true]" echo DEBUG: Skipping %%j because it's already been checked
					)
				)
			)
			rem check for requires string
			echo "!item!" 2>&1 | findstr /R /I /C:"^.rem Requires .*$" 2>&1 > nul
			if NOT ERRORLEVEL 1 (
				if "[%debug%]"=="[true]" echo DEBUG: Line is Requires Statment
				for /f "tokens=3" %%j IN ('echo "!item! "') do (
					if "[%debug%]"=="[true]" echo DEBUG: %%j is a Requirement
					call s_which %%j
					if "[%debug%]"=="[true]" echo DEBUG: Path to item is "!_path!"
					if "!_path!" == "" (
						dir /b %~dp1 | findstr /I /C:"%%j" >nul
						if ERRORLEVEL 1 (
							if "[%debug%]"=="[true]" echo DEBUG: %%j on line !line! of %~1 doesn't exist
							echo %%j was not found, please check the script for typos
							echo or the extensions directory for missing components
							pause
							exit 1
						) else (
							if "[%debug%]"=="[true]" echo DEBUG: %%j was found in the current directory
						)
					) else (
						if "[%debug%]"=="[true]" echo DEBUG: %%j was found in path
					)
				)
			)
		)
	)
) else (
	if "[%debug%]"=="[true]" echo DEBUG: %1 doesn't exist
	echo An Error Has Occured while attempting to run the selftest
	echo Please make sure the script is formated properly and run again
	pause
	exit 1
)
if %depth%==1 (
	if %spinnerenabled%==true call mod_spinner /clear
	echo The Self Check Has Passed
)
set /a depth-=1
endlocal & set "checked=%checked% %~n1" & if %spinnerenabled%==true set "spinner=%spinner%"
goto :EOF

:flag_check

