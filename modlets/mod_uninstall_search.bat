@echo off
setlocal enabledelayedexpansion
call mod_flag_parsing %*
call mod_flag_check /type string /flag name
call mod_flag_check /type boolean /flag match-all /defaultValue false
call mod_flag_check /type boolean /flag confirm /defaultValue false
call mod_flag_check /type boolean /flag allow-non-msi /defaultValue false

set "productname="
set "uninstallstring="

echo Looking for uninstall strings for %flag_name%
echo Part 1 of 2
echo/ > nul & call :uninstall %flag_name% "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
if errorlevel 1 (
	exit /b
)
call mod_spinner /clear
echo Part 2 of 2
echo/ > nul & call :uninstall %flag_name% "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
if errorlevel 1 (
	exit /b
)
call mod_spinner /clear
if %flag_match-all%==false (
	if defined saveduninstallstring (
		echo %saveduninstallstring% | findstr /i /c:"MsiExec.exe" >nul
		if Not ERRORLEVEL 1 (
			for /f "usebackq tokens=2 delims={}" %%i in (`echo %saveduninstallstring%`) do (
				call mod_echo Uninstalling %productname%...
				call mod_log Uninstalling %productname% via {%%i}
				call mod_uninstall_guid /guid {%%i}
			)
		) else (
			if %flag_allow-non-msi%==true (
				call mod_run %saveduninstallstring%
			) else (
				call mod_tee Warning: Ignoring non-msi uninstaller /color 0E
			)
		)
	) else (
		mod_tee ERROR: No Matching Uninstaller Found /color 0E
	)
) else (
	if NOT defined uninstallstring (
		mod_tee ERROR: No Matching Uninstallers Found /color 0E
	)
)
exit /b

:uninstall
@echo off
for /f "tokens=*" %%I in ('reg query "%~2"') do (
	set query=%%I
	set query=!query:HKEY_LOCAL_MACHINE=HKLM!
	reg query "!query!" 2>&1 | findstr /i /C:"DisplayName" | findstr /i /C:%1 > nul
	if not ERRORLEVEL 1 (
		for /f "tokens=1,2,*" %%J in ('reg query "!query!" 2^>nul') do (
			echo %%J | findstr /i /C:"UninstallString" > nul
			if NOT ERRORLEVEL 1 (
				set "uninstallstring=%%L"
			)
			echo %%J | findstr /i /C:"DisplayName" > nul
			if NOT ERRORLEVEL 1 (
				set "productname=%%L"
			)
		)
		if defined productname (
			if defined uninstallstring (
				if %flag_match-all%==true (
					echo !uninstallstring! | findstr /i /c:"MsiExec.exe" >nul
					if Not ERRORLEVEL 1 (
						for /f "usebackq tokens=2 delims={}" %%i in (`echo !uninstallstring!`) do (
							call mod_echo Uninstalling !productname!...
							call mod_log Uninstalling !productname! via {%%i}
							call mod_uninstall_guid /guid {%%i}
						)
					) else (
						if %flag_allow-non-msi%==true (
							call mod_run !uninstallstring!
						) else (
							call mod_tee Ignoring non-msi uninstaller /color 0E
						)
					)
				) else (
					if defined saveduninstallstring (
						call mod_tee ERROR: More than one matching uninstaller, Aborting /color 0C
						set /a errorct+=1
						exit /b 1
					) else (
						set saveduninstallstring=!uninstallstring!
					)
				)
				rem echo !productname! can be uninstalled with !uninstallstring!
				rem echo.
			) else (
				call mod_tee No uninstall string for !productname! /color 0E
			)
		)
	)
	call mod_spinner /speedhack
)
exit /b 0