@echo off
REM if "[%path:~-1%]" == "[;]" (
	REM set path=%path%%~dp0extensions;
REM ) else (
	REM set path=%path%;%~dp0extensions
REM )

if not exist %~dp0extensions\runfromprocess-x64.exe (
	echo this requires runfromprocess-x64 in the extensions folder
	pause
	exit /b 1
)

if not defined run_script_location (
	echo The run_script didn't save its location properly
	rem pause
	exit /b 1
	set run_script_location=cmd.exe
)
rem echo %path%
for /f "usebackq tokens=2" %%u IN (`query session ^| findstr /C:Active`) do (
	if defined user ( 
		echo Multiple active users 
		exit /b 1 
	) else ( 
		set "user=%%u"
	)
)
echo user: %user%

for /f "usebackq skip=1" %%s IN (`wmic useraccount where name^='%user%' get sid`) do if not defined sid ( set "sid=%%s" )
echo sid: %sid%

rem TODO: Check if user is in admin group

for /f "usebackq tokens=3*" %%p IN (`REG QUERY "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\%sid%" /v "ProfileImagePath"`) do set home=%%p %%q
echo home: %home%

for /f "usebackq tokens=2 skip=3" %%p IN (`tasklist /fi "USERNAME eq %USER%" /FI "IMAGENAME eq explorer.exe"`) do if not defined explorerPid (set explorerPid=%%p)
echo explorer PID: %explorerpid%

start "" /min /wait %~dp0extensions\runfromprocess-x64.exe %explorerpid% cmd.exe /C taskmgr.exe
timeout /nobreak 3 > nul
for /f "usebackq tokens=2 skip=3" %%p IN (`tasklist /fi "USERNAME eq %USER%" /FI "IMAGENAME eq taskmgr.exe"`) do if not defined taskmgrPid (set taskmgrPid=%%p)
echo taskmgr PID: %taskmgrpid%
rem TODO: Check if taskmgr is elevated
set forceinteractive=false
start "" /min /wait %~dp0extensions\runfromprocess-x64.exe %taskmgrpid% cmd.exe /c timeout 5 /nobreak ^& %run_script_location%

for /f "usebackq skip=1" %%p IN (`wmic process where parentprocessid^=%taskmgrPID% get processid`) do (
	if %%p geq 0 (
		for /f "usebackq tokens=1 skip=3" %%q IN (`tasklist /fi "PID eq %%p"`) do (
			if "[%%q]" == "[cmd.exe]" (
				if not defined cmdpid (
					set cmdpid=%%p
				) else (
					echo multiple CMD processes, this shouldn't happen
					pause
					exit /b 1
				)
			)
		)
	)
)
echo cmd PID: %cmdpid%
taskkill /PID %taskmgrpid% /F
rem pause