@echo off
title MADS_init

REM This script establishes a connection to the core file which then kicks off the deployment process

REM Change to the script's directory
cd /d %~dp0

REM Check for Admin Permissions
echo Administrative permissions required. Detecting permissions...
net session >nul 2>&1
if ERRORLEVEL 1 (
	echo Failure: Current permission inadequate
	REM Create elevate.vbs to get us admin
	echo Set UAC = CreateObject^("Shell.Application"^) > %temp%\elevate.vbs
	echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> %temp%\elevate.vbs
	REM Test if network share
	net use | findstr /C:%~d0 > nul
	if NOT ERRORLEVEL 1 (
		REM Network share confirmed
		copy %~nx0 %temp%\%~nx0
	)
	start "" /wait %SystemRoot%\System32\wscript.exe %temp%\elevate.vbs
	if ERRORLEVEL 1 (
		echo Error Getting Admin, please launch manually
		pause
		exit 1
	) else (
		exit 0
	)
	
) else (
	echo Success: Administrative Permissions Confirmed
	echo.
)

REM Defaults:
REM This section can be used to create a single file launcher without the need for a settings.ini file
set drive_letter=
set core_location=
set username=
set password=
set room=
set mode=

REM Load Settings:
REM This section loads relevant data from the settings.ini file
if exist "settings.ini" (
	for /F "usebackq delims=" %%a in ("%~dp0settings.ini") do (
		echo %%a | findstr /r /C:"^[a-z_][a-z_]*  *=  *.*" > nul
		if NOT ERRORLEVEL 1 (
			for /F "usebackq tokens=1" %%b in (`echo %%a`) do (
				if %%b == drive_letter (
					for /F "usebackq tokens=3" %%c in (`echo %%a`) do (
						set drive_letter=%%c
					)
				)
				if %%b == core_location (
					for /F "usebackq tokens=3" %%c in (`echo %%a`) do (
						set core_location=%%c
					)
				)
				if %%b == username (
					for /F "usebackq tokens=3" %%c in (`echo %%a`) do (
						set username=%%c
					)
				)
				if %%b == password (
					for /F "usebackq tokens=3" %%c in (`echo %%a`) do (
						set password=%%c
					)
				)
				if %%b == room (
					for /F "usebackq tokens=3" %%c in (`echo %%a`) do (
						set room=%%c
					)
				)
				if %%b == mode (
					for /F "usebackq tokens=3" %%c in (`echo %%a`) do (
						set mode=%%c
					)
				)
			)
		)
	)
)

REM Build a mount command:
REM This section constructs a "mount command" which will be used to mount a network share
set mount_drive=net use
if defined drive_letter (
	set mount_drive=%mount_drive% %drive_letter%:
) else (
	for %%i in (A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z) do (
		subst %%i: %SystemDrive%\ > nul
		if NOT ERRORLEVEL 1 (
			subst %%i: /d > nul
			set mount_drive=%mount_drive% %%i:
			set drive_letter=%%i
		)
	)
	if not defined drive_letter (
		echo ERROR: No Free Drive Letters, Aborting...
		pause
		exit 1
	)
)
REM Prompt for Missing core Location Information:
if defined core_location (
	set mount_drive=%mount_drive% %core_location%
) else (
	set /p "core_location=MADS core location: "
	call set mount_drive=%mount_drive% %%core_location%%
)
if defined username (
	if defined password (
		set mount_drive=%mount_drive% /USER:%username% %password%
	) else (
		set mount_drive=%mount_drive% /USER:%username%
	)
)

REM Mount Drive if needed and Change Directories:
if "[%core_location:~0,2%]" == "[\\]" (
	%mount_drive%
	if ERRORLEVEL 1 (
		echo ERROR: Couldn't mount share
		pause
		exit 5
	)
	cd /d %drive_letter%:
		if ERRORLEVEL 1 (
		echo ERROR: Couldn't access directory
		net use %drive_letter%: /delete /yes
		pause
		exit 5
	)
) else (
	cd /d %core_location%
	if ERRORLEVEL 1 (
		echo ERROR: Couldn't access directory
		pause
		exit 5
	)
)

REM Prompt for Missing Room Name:
if NOT defined room (
	set /p "room=room: "
)
cls

REM Check for the Powershell version of the core if it exists and powershell V2 or higher is installed
if "[%mode%]" == "[auto]" (
	echo Checking Powershell script...
	if exist MADS_core.ps1 (
		cls
		echo Checking if Powershell Installed...
		if exist %systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe (
			cls
			echo Checking Powershell Version...
			%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -command "exit $PSVersionTable.PSVersion.Major"
			if ERRORLEVEL 2 (
				cls
				echo Switching to Powershell
				echo.
				set mode=powershell
			) else (
				echo Powershell Version Not Supported
				set mode=batch
			)
		) else (
			echo Powershell Not Installed
			set mode=batch
		)
	) else (
		echo No Powershell Script
		set mode=batch
	)
)

REM Check for MADS_core:
if "[%mode%]" == "[powershell]" (
	if NOT exist MADS_core.ps1 (
		echo ERROR: MADS_core.ps1 not found please check directory
		if "[%core_location:~0,2%]" == "[\\]" (
			net use %drive_letter%: /delete /yes
		)
		pause
		exit 1
	)
) else (
	if NOT exist MADS_core.bat (
		echo ERROR: MADS_core.bat not found please check directory
		if "[%core_location:~0,2%]" == "[\\]" (
			net use %drive_letter%: /delete /yes
		)
		pause
		exit 1
	)
)
REM Run core
echo Launching MADS room: %room%...
if exist C:\Windows\Sysnative\ (
	if "[%mode%]" == "[powershell]" (
		start "" /wait %systemroot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File .\MADS_core.ps1 /room %room%
	) else (
		start "" /wait C:\Windows\Sysnative\cmd.exe /c MADS_core.bat /room %room%
	)
) else (
	if "[%mode%]" == "[powershell]" (
		start "" /wait %systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File .\MADS_core.ps1 /room %room%
	) else (
		start "" /wait C:\Windows\System32\cmd.exe /c MADS_core.bat /room %room%
	)
)

set error=%errorlevel%
cd /d %~dp0

echo done
timeout 2
if "[%core_location:~0,2%]" == "[\\]" (
	net use %drive_letter%: /delete /yes
)
exit %error%