@echo off
setlocal EnableDelayedExpansion

:: Set Title
title MADS_core

:: Load Room
if exist room_%~2.ini (
	for /F "usebackq tokens=* delims=" %%a in ("room_%~2.ini") do (
		set scripts=%%a
	)
) else (
	echo Error Loading Room: room_%~2.ini
	pause
	exit 1
)

:: Log Setup
echo %~n0: ================== Script Start ================== >> %temp%\updater.log

echo %~n0: %~n0 Version: 1.6.3 >> %temp%\updater.log
echo %~n0: Computer Name: %computername% >> %temp%\updater.log
echo %~n0: IP Addresses: >> %temp%\updater.log
set ip_address_string="IPv4 Address"
for /f "usebackq tokens=2 delims=:" %%f in (`ipconfig ^| findstr /c:%ip_address_string%`) do echo %~n0:%%f >> %temp%\updater.log
echo. >> %temp%\updater.log

:: Get Directories
set "core=.\"
set "modules=.\"
if exist "settings.ini" (
	for /F "usebackq delims=" %%a in ("%~dp0settings.ini") do (
		echo %%a | findstr /r /C:"^[a-z][a-z]*  *=  *.*" > nul
		if NOT ERRORLEVEL 1 (
			for /F "usebackq tokens=1" %%b in (`echo %%a`) do (
				if %%b == core (
					for /F "usebackq tokens=3" %%c in (`echo %%a`) do (
						set "core=%%c"
					)
				)
				if %%b == modules (
					for /F "usebackq tokens=3" %%c in (`echo %%a`) do (
						set "modules=%%c"
					)
				)
			)
		)
	)
)

echo Core Directory: %core%
echo %~n0: Core Directory: %core% >> %temp%\updater.log
echo Module Directory: %modules%
echo %~n0: Module Directory: %modules% >> %temp%\updater.log
echo.
echo. >> %temp%\updater.log

echo %~n0: Loaded Room: room_%~2.ini  >> %temp%\updater.log
echo %~n0: Scripts: %scripts% >> %temp%\updater.log
echo. >> %temp%\updater.log

:: Set Extensions Path
set "path=%path%;%~dp0extensions\;%~dp0modlets\"

:: Enumerate Extensions
echo Extensions:
echo %~n0: Extensions: >> %temp%\updater.log
for /f %%f in ('dir /b %~dp0extensions\') do (
	echo %%~nf
	echo %~n0: %%~nf >> %temp%\updater.log
)
echo.
echo. >> %temp%\updater.log

:: Check for window manipulation powers
set minimizable=false
call s_which nircmd.exe
if not "%_path%" == "" (
	set minimizable=true
)
if exist nircmd.exe (
	set minimizable=true
)
echo nircmd?=%minimizable%
echo %~n0: nircmd?=%minimizable% >> %temp%\updater.log
echo.
echo. >> %temp%/updater.log

:: manipulate windows if we have the power
if [%minimizable%]==[true] (
	nircmd win min ititle MADS_init
	rem nircmd win move ititle updater_main 0,0
	nircmd win setsize ititle MADS_core 0 0 680 340
)

:: set the start time and format it
set STARTTIME=%TIME%
for /F "tokens=1-4 delims=:.," %%a in ("%STARTTIME%") do (
   set /A "start=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)

echo Start    : %date% @ %STARTTIME%
echo %~n0: Start    : %date% @ %STARTTIME% >> %temp%\updater.log

:: More Log Setup
echo %~n0: updater core start >> %temp%\updater.log
echo %~n0: command line: %scripts% >> %temp%\updater.log
echo. >> %temp%\updater.log
set /a errorct=0

:: Run the Pre-Script Process
if exist updater_start\updater_start.bat (
	start "" /wait updater_start\updater_start.bat
	if ERRORLEVEL 1 (
		echo.
		echo errors occured while trying to execute pre-script process
		echo %~n0: errors occured while trying to execute pre-script process >> %temp%\updater.log
		echo.
		echo. >> %temp%\updater.log
	)
) else (
	echo No Pre-Script Proccess
)

echo.
echo. >> %temp%\updater.log

cd %modules%
:: Main process 
for %%x in (%scripts%) do (
	echo %%x module starting
	echo %~n0: %%x module starting >> %temp%\updater.log
	REM set MODULESTARTTIME=!TIME!
	REM for /F "tokens=1-4 delims=:.," %%a in ("!MODULESTARTTIME!") do (
	   REM set /A "modulestart=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
	REM )

	echo Start    : !date! @ !MODULESTARTTIME!
	echo %~n0: Start    : !date! @ !MODULESTARTTIME! >> %temp%\updater.log
	cd %%x
	if exist %%x.bat (
		start "MADS_module: %%x" /wait %%x.bat
		if ERRORLEVEL 1 (
			echo %%x module done with 1 or more errors
			echo %~n0: %%x module done with 1 or more errors >> %temp%\updater.log
			set /a errorct+=1
		) else (
			echo %%x module done
			echo %~n0: %%x module done >> %temp%\updater.log
		)
	) else (
		echo %%x module not found
		echo %~n0: %%x module not found >> %temp%\updater.log
		set /a errorct+=1
	)
	cd ..
	
	REM set MODULEENDTIME=!TIME!
	REM for /F "tokens=1-4 delims=:.," %%a in ("!MODLUEENDTIME!") do (
	   REM set /A "moduleend=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
	REM )
	REM set /A moduleelapsed=!moduleend!-!modulestart!
	
	REM set /A hh=!moduleelapsed!/(60*60*100)
	REM set /A rest=!moduleelapsed!%%(60*60*100)
	REM set /A mm=!rest!/(60*100)
	REM set /A rest%%=60*100
	REM set /A ss=!rest!/100
	REM set /A cc=!rest!%%100
	REM if !hh! lss 10 set hh=0!hh!
	REM if !mm! lss 10 set mm=0!mm!
	REM if !ss! lss 10 set ss=0!ss!
	REM if !cc! lss 10 set cc=0!cc!

	REM set MODULEDURATION=!hh!:!mm!:!ss!.!cc!

	REM echo Finish   : !date! @ !MODULEENDTIME!
	REM echo          ---------------
	REM echo Duration : !MODULEDURATION!

	REM echo %~n0: Finish   : !date! @ !MODULEENDTIME! >> %temp%\updater.log
	REM echo %~n0:          --------------- >> %temp%\updater.log
	REM echo %~n0: Duration : !MOEDULEDURATION!  >> %temp%\updater.log
	echo.
	echo. >> %temp%\updater.log

)
echo complete
echo %~n0: complete >> %temp%\updater.log
cd /d %~dp0

:: Set the end time
set ENDTIME=%TIME%

:: Change formatting for the start and end times

for /F "tokens=1-4 delims=:.," %%a in ("%ENDTIME%") do (
   set /A "end=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)

:: Calculate the elapsed time by subtracting values
set /A elapsed=end-start

:: Format the results for output
set /A hh=elapsed/(60*60*100), rest=elapsed%%(60*60*100), mm=rest/(60*100), rest%%=60*100, ss=rest/100, cc=rest%%100
if %hh% lss 10 set hh=0%hh%
if %mm% lss 10 set mm=0%mm%
if %ss% lss 10 set ss=0%ss%
if %cc% lss 10 set cc=0%cc%

set DURATION=%hh%:%mm%:%ss%.%cc%

:: Output Runtime

echo Finish   : %date% @ %ENDTIME%
echo          ---------------
echo Duration : %DURATION% 

echo %~n0: Finish   : %date% @ %ENDTIME% >> %temp%\updater.log
echo %~n0:          --------------- >> %temp%\updater.log
echo %~n0: Duration : %DURATION%  >> %temp%\updater.log

:: Check for Errors and run the corresponding post-script process 
if %errorct% NEQ 0 (
	if exist updater_end_incomplete\updater_end_incomplete.bat (
		start "" /wait updater_end_incomplete\updater_end_incomplete.bat
		if ERRORLEVEL 1 (
			echo.
			echo errors occured while trying to execute post-script process
			echo %~n0: errors occured while trying to execute post-script process >> %temp%\updater.log
			echo.
		)
	) else (
		echo No Post-Script Proccess
	)
	echo errors have occured in %errorct% modules, please check the log file
	echo %~n0: errors have occurred in %errorct% modules, please check the log file >> %temp%\updater.log
	if [%minimizable%]==[true] (
		timeout /nobreak 2 > nul
		nircmd win activate ititle updater_main
	)
	choice /M "Do you want to view the log?"
	if ERRORLEVEL 2 ( 
		echo > nul
	) else (
		if ERRORLEVEL 1 (
			start notepad++.exe %temp%/updater.log -n999999
		)
	)
) else (
	if exist updater_end_complete\updater_end_complete.bat (
		start /wait updater_end_complete\updater_end_complete.bat
		if ERRORLEVEL 1 (
			echo.
			echo errors occured while trying to execute post-script process
			echo %~n0: errors occured while trying to execute post-script process >> %temp%\updater.log
			echo.
			echo. >> %temp%\updater.log
		)
	) else (
		echo No Post-Script Proccess
	)
)
echo %~n0: =================== Script End =================== >> %temp%\updater.log
echo. >> %temp%\updater.log
echo. >> %temp%\updater.log

:: manipulate windows if we have the power
if [%minimizable%]==[true] (
	nircmd win min ititle MADS_core
	nircmd win normal ititle MADS_init
)

exit /b