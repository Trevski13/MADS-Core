@echo off
setlocal EnableDelayedExpansion

if NOT exist %1 (
	call s_which %~nx1
	if defined _path (
		if "[%debug%]"=="[true]" echo DEBUG: Reloading with "!_path!"
		call %~nx0 !_path!
		exit /b 0
	)
)
rem increment the depth counter (aka how manytimes we've called ourselves), as an abnormal increase in this may indicate a dependency loop.
if NOT defined depth (
	echo Self Check
	echo Loading...
	set depth=1
	set "builtin="
	if exist "%temp%\MADS\cache\SelfTest\builtin.ini" (
		for /F "usebackq tokens=* delims=" %%c in ("%temp%\MADS\cache\SelfTest\builtin.ini") do (
			set builtin=%%c
		)
	) else (
		for /f "tokens=1 usebackq" %%c in (`help`) do (
			echo %%c|findstr /rc:"^[ABCDEFGHIJKLMNOPQRSTUVWXYZ]*$" > nul
			if NOT ERRORLEVEL 1 (
				set builtin=!builtin! %%c
			)
		)
	)
) else (
	set /a depth+=1
)
if %depth%==1 (
	if exist "%temp%\MADS\cache\SelfTest\checked.ini" (
		for /F "usebackq tokens=* delims=" %%c in ("%temp%\MADS\cache\SelfTest\checked.ini") do (
			set checked=%%c
		)
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
	call s_which fciv.exe
	if not "[!_path!]" == "[]" (
		set hash=!_path!
	) else (
		set "hash="
	)
	if defined hash (
		if NOT exist "%temp%\MADS\cache\SelfTest\" (
			mkdir "%temp%\MADS\cache\SelfTest\"
		)
		if NOT exist "%temp%\MADS\cache\SelfTest\fciv.exe" (
			copy  /B /V /Y "!_path!" "%temp%\MADS\cache\SelfTest\fciv.exe" 2>&1 >nul
		)
		if exist "%temp%\MADS\cache\SelfTest\fciv.exe" (
			set hash=%temp%\MADS\cache\SelfTest\fciv.exe
		)
	)
	if 1==2 (
	if NOT defined checked (
		if defined hash (
			if exist %corelocation%SelfTest_cache\ (
				if not exist %temp%\MADS\Cache\SelfTest_cache\ (
					mkdir %temp%\MADS\Cache\SelfTest_cache\
				)
				for /f "usebackq" %%f in (`dir /b %corelocation%SelfTest_cache\`) do (
					copy  /B /V /Y "%corelocation%SelfTest_cache\%%~nxf" "%temp%\MADS\Cache\SelfTest_cache\%%~nxf" 2>&1 >nul
				)
				echo exists
				for /f "tokens=*" %%m in ('dir /b "%temp%\MADS\Cache\SelfTest_cache\" ^| findstr /bic:full_requirements_') do (
					set canload=true
					if !spinnerenabled!==true call mod_spinner /speedhack
					for /F "usebackq tokens=* delims=" %%r in ("%temp%\MADS\Cache\SelfTest_cache\%%m") do (
						set requires=%%r
					)
					for %%r in (!requires!) do (
						rem if !spinnerenabled!==true call mod_spinner /speedhack
						echo !checked! | findstr /i /C:"%%r" 2>&1 >nul
						if ERRORLEVEL 1 (
							rem if !spinnerenabled!==true call mod_spinner /speedhack
							if exist %temp%\MADS\Cache\SelfTest_cache\requirements_%%r.ini (
								if exist %temp%\MADS\Cache\SelfTest_cache\requirements_%%r.verified (
									if exist %%r (
										for /f usebackq^ skip^=3 %%i in (`%hash% -add %%r -sha1`) do set hashvalue=%%i
									) else (
										echo %%r | findstr /i /C:".bat" > nul
										if ERRORLEVEL 1 (
											call s_which %%r.bat
										) else (
											call s_which %%r
										)
										rem echo %hash% -add !_path! -sha1
										for /f usebackq^ skip^=3 %%i in (`%hash% -add !_path! -sha1`) do set hashvalue=%%i
									)
									for /F "usebackq delims=" %%i in ("%temp%\MADS\Cache\SelfTest_cache\requirements_%%~nr.verified") do set verifiedhash=%%i
									rem echo %%m: %%r: saved: !verifiedhash! actual: !hashvalue!
									if NOT "[!hashvalue!]" == "[!verifiedhash!]" (
										set canload=false
									)
								)
							)
						)
					)
					rem echo canload %%m: !canload!
					rem pause
					if !canload!==true (
						for %%r in (!requires!) do (
							echo !checked! | findstr /i /C:"%%r" 2>&1 >nul
							if ERRORLEVEL 1 (
								set checked=!checked! %%r
							)
						)
					)
				)
			)
		)
	)
	)
	rem echo %corelocation%SelfTest_cache\
	if not exist %temp%\MADS\Cache\SelfTest\requirements_* (
		if exist "%corelocation%SelfTest_cache\" (
			for /f "usebackq" %%f in (`dir /b %corelocation%SelfTest_cache\`) do (
				copy  /B /V /Y "%corelocation%SelfTest_cache\%%~nxf" "%temp%\MADS\Cache\SelfTest\%%~nxf" 2>&1 >nul
			)
		)
	)
	echo Loaded
	echo Running...
	rem check hashes if we can and load them into "checked"
	rem call :hashing
) else (
	if "[%debug%]"=="[true]" echo DEBUG: Self on "%~1" at level %depth%
)

rem check for "over depth" idealy you shouldn't go over 6 e.g. copy-newest->copy->tee->echo->flag_check->flag_parse but there's plenty of breathing room if needed
if %depth% geq 10 (
	echo Recusion limit reached, please check scripts for dependency loops
	pause
	exit 1
)

set line=0
rem check to make sure we actually were given an item to check
if "[%1]"=="[]" (
	echo An Error Has Occured while attempting to run the selftest
	echo Please make sure the script is formated properly and run again
	echo ERROR: "%%1" is blank
	pause
	exit 1
)

if exist "%temp%\MADS\cache\SelfTest\requirements_%~n1.ini" (
	if defined hash (
		set exists=false
		if exist "%temp%\MADS\cache\SelfTest\requirements_%~n1.verified" (
			set exists=true
		) else (
			if exist "%corelocation%SelfTest_cache\requirements_%~n1.verified" (
				copy  /B /V /Y "%corelocation%SelfTest_cache\requirements_%~nx1.verified" "%temp%\MADS\Cache\SelfTest\requirements_%~nx1.verified" 2>&1 >nul
				copy  /B /V /Y "%corelocation%SelfTest_cache\requirements_%~nx1.ini" "%temp%\MADS\Cache\SelfTest\requirements_%~nx1.ini" 2>&1 >nul
				set exists=true
			)
		)
		if !exists! == true (
			if exist %1 (
				rem echo %hash% -add %1 -sha1
				for /f usebackq^ skip^=3 %%i in (`%hash% -add %1 -sha1`) do set hashvalue=%%i
			) else (
				echo %1 | findstr /i /C:".bat" > nul
				if ERRORLEVEL 1 (
					call s_which %1.bat
				) else (
					call s_which %1
				)
				rem echo %hash% -add !_path! -sha1
				for /f usebackq^ skip^=3 %%i in (`%hash% -add !_path! -sha1`) do set hashvalue=%%i
			)
			for /F "usebackq delims=" %%i in ("%temp%\MADS\cache\SelfTest\requirements_%~n1.verified") do set verifiedhash=%%i
			set validrequirements=false
			if !hashvalue! == !verifiedhash! (
				set validrequirements=true
			) else (
				if exist %corelocation%SelfTest_cache\requirements_%~n1.ini (
					if exist %corelocation%SelfTest_cache\requirements_%~n1.verified (
						copy  /B /V /Y "%corelocation%SelfTest_cache\requirements_%~nx1.verified" "%temp%\MADS\Cache\SelfTest\requirements_%~nx1.verified" 2>&1 >nul
						copy  /B /V /Y "%corelocation%SelfTest_cache\requirements_%~nx1.ini" "%temp%\MADS\Cache\SelfTest\requirements_%~nx1.ini" 2>&1 >nul
						for /F "usebackq delims=" %%i in ("%temp%\MADS\cache\SelfTest\requirements_%~n1.verified") do set verifiedhash=%%i
						if !hashvalue! == !verifiedhash! (
							set validrequirements=true
						)
					)
				)
			)
			if !validrequirements! == true (
				for /F "usebackq tokens=* delims=" %%r in ("%temp%\MADS\cache\SelfTest\requirements_%~n1.ini") do (
					rem echo Requirements:%%r
					for %%j in (%%r) do (
						rem set /a dospinner=!line! %% 1
						rem if !dospinner!==0 
						if %spinnerenabled%==true call mod_spinner /speedhack
						echo !checked! | findstr /i /C:"%%j" 2>&1 >nul
						if ERRORLEVEL 1 (
							echo %%j | findstr /i /c:"%~n0" /c:"s_which" 2>&1 >nul
							if ERRORLEVEL 1 (
								if "[%debug%]"=="[true]" echo DEBUG: Now Checking %%j
								if "!_path!" == "" (
									echo %%j | findstr /i /C:".bat" > nul
									if ERRORLEVEL 1 (
										rem echo quickChecking %%j
										call %~n0 %%j.bat
									) ELSE (
										rem echo quickChecking %%j
										call %~n0 %%j
									)
								) else (
									echo %%j | findstr /i /C:".bat" > nul
									if ERRORLEVEL 1 (
										call s_which %%j.bat
									) else (
										call s_which %%j
									)
									rem echo quickChecking %%j
									call %~n0 !_path!
								)
								if "[%debug%]"=="[true]" echo DEBUG: Finished Checking %%j
							)
						) else (
							if "[%debug%]"=="[true]" echo DEBUG: Skipping %%j because it's already been checked
						)
					)
					if %depth%==1 (
						if %spinnerenabled%==true call mod_spinner /clear
						echo The Self Check Has Passed
						echo !checked!> "%temp%\MADS\cache\SelfTest\checked.ini"
						echo %builtin%> "%temp%\MADS\cache\SelfTest\builtin.ini"
					)
					set /a depth-=1
					goto :end
				)
			)
		)
	) else (
		if "[%debug%]"=="[true]" echo DEBUG: No Hashing
	)
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
			if "[%debug%]"=="[true]" echo DEBUG: Checking line "!item!"
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
							echo %builtin%| findstr /I /C:"%%j" >nul
							if ERRORLEVEL 1 (
								echo %%j was not found, please check the script for typos
								echo or the modlet directory for missing modlets
								echo ERROR: %%j on line !line! of %~1 doesn't exist
								pause
								exit 1
							)
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
					echo !requirements_%~n1!| findstr /C:"%%j" >nul
					if ERRORLEVEL 1 (
						set requirements_%~n1=!requirements_%~n1! %%j
					)
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
							echo %%j was not found, please check the script for typos
							echo or the extensions directory for missing components
							echo ERROR: %%j on line !line! of %~1 doesn't exist
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
	echo An Error Has Occured while attempting to run the selftest
	echo Please make sure the script is formated properly and run again
	echo ERROR: %1 doesn't exist
	pause
	exit 1
)
if %depth%==1 (
	if %spinnerenabled%==true call mod_spinner /clear
	echo The Self Check Has Passed
	echo %checked%> "%temp%\MADS\cache\SelfTest\checked.ini"
	echo %builtin%> "%temp%\MADS\cache\SelfTest\builtin.ini"
)
if not exist "%temp%\MADS\Cache\SelfTest\" (
	mkdir "%temp%\MADS\Cache\SelfTest\"
)
if defined requirements_%~n1 (
	echo !requirements_%~n1!> "%temp%\MADS\Cache\SelfTest\requirements_%~n1.ini"
) else (
	echo.> "%temp%\MADS\Cache\SelfTest\requirements_%~n1.ini"
)
if defined hash (
	if exist %1 (
		rem echo %hash% -add %1 -sha1
		for /f usebackq^ skip^=3 %%i in (`%hash% -add %1 -sha1`) do set hashvalue=%%i
	) else (
		echo %1 | findstr /i /C:".bat" > nul
		if ERRORLEVEL 1 (
			set s_which %1.bat
		) else (
			call s_which %1
		)
		echo %hash% -add !_path! -sha1
		for /f usebackq^ skip^=3 %%i in (`%hash% -add !_path! -sha1`) do set hashvalue=%%i
	)
	echo !hashvalue!> %temp%\MADS\cache\SelfTest\requirements_%~n1.verified
)
set /a depth-=1
:end
endlocal & set "checked=%checked% %~n1" & if %spinnerenabled%==true set "spinner=%spinner%"
goto :EOF

:hashing
"%temp%\MADS\SelfTest\%~n1.requirements"
:hashing2
setlocal
for /f tokens=1,2* %%i in ("%requirements%") do (
	
)
endlocal
exit /b

