@echo off
title MADS_init

REM This script establishes a connection to the core file which then kicks off the deployment process
REM VERSION: V2

REM Defaults:
REM This section can be used to create a single file launcher without the need for a settings.ini file
set drive_letter=
set core_location=
set username=
set password=
set room=
set scripts=
set mode=
set debug=false
REM Change to the script's directory
pushd %~dp0

REM Check for Admin Permissions
echo Administrative permissions required. Detecting permissions...
net session >nul 2>&1
if ERRORLEVEL 1 (
	echo Failure: Current permission inadequate
	REM Create temp directory if it doesn't exist
	if not exist "%temp%\MADS\" (
		mkdir "%temp%\MADS\"
	)
	REM Create elevate.vbs to get us admin
	echo Set UAC = CreateObject^("Shell.Application"^) > %temp%\MADS\elevate.vbs
	echo UAC.ShellExecute WScript.Arguments^(0^), "", "", "runas", 1 >> %temp%\MADS\elevate.vbs
	REM Test if network share
	net use | findstr /C:%~d0 > nul
	if NOT ERRORLEVEL 1 (
		REM Network share confirmed
		copy %~nx0 %temp%\MADS\%~nx0
		copy settings.ini %temp%\MADS\settings.ini 2>nul
		set location=%temp%\MADS\%~nx0
	) else (
		set location=%~f0
	)
	call start "" /wait %SystemRoot%\System32\wscript.exe %temp%\MADS\elevate.vbs "%%location%%"
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

REM Overrides:
REM This section can be used to override settings in a settings.ini file (use with caution)
REM set drive_letter=
REM set core_location=
REM set username=
REM set password=
REM set room=
REM set mode=

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
	if NOT defined scripts (
		set /p "room=room: "
	)
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
		echo ERROR: MADS_core.ps1 not found in %core_location% please check directory
		if "[%core_location:~0,2%]" == "[\\]" (
			net use %drive_letter%: /delete /yes
		)
		pause
		exit 1
	)
) else (
	if NOT exist MADS_core.bat (
		echo ERROR: MADS_core.bat not found in %core_location% please check directory
		if "[%core_location:~0,2%]" == "[\\]" (
			net use %drive_letter%: /delete /yes
		)
		pause
		exit 1
	)
)
REM Run core
if defined room (
	set args=/room %room%
) else (
	if defined scripts (
		set args=/direct %scripts%
	) else (
		set args=/manual
	)
)
echo Launching MADS: %args%...
if exist C:\Windows\Sysnative\ (
	if "[%mode%]" == "[powershell]" (
		start "" /wait %systemroot%\Sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File .\MADS_core.ps1 %args%
	) else (
		start "" /wait C:\Windows\Sysnative\cmd.exe /c MADS_core.bat %args%
	)
) else (
	if "[%mode%]" == "[powershell]" (
		start "" /wait %systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File .\MADS_core.ps1 %args%
	) else (
		start "" /wait C:\Windows\System32\cmd.exe /c MADS_core.bat %args%
	)
)


set error=%errorlevel%
cd /d %~dp0

echo done
timeout 2
if "[%core_location:~0,2%]" == "[\\]" (
	net use %drive_letter%: /delete /yes
)
popd
exit %error%