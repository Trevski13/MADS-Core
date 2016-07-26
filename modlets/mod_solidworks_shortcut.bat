@echo off
rem Requires strings.exe

REM for /f " tokens=*" %%d in ('dir /B /ad-h /OD "C:\Program Files\Solidworks Corp\" ^| findstr /i /R /C:"^solidworks$" /C:"^solidworks ([0-9]*)$"') do (
	REM if exist 
	REM set newestjdkdir=%CD%\%%d
REM )

call s_which strings.exe
if NOT "!_path!" == "" (
	set "exeloc=strings.exe"
	if %debug%==true echo DEBUG: Found strings.exe in path location !_path!
)
if exist strings.exe (
	set "exeloc=strings.exe"
		if %debug%==true echo DEBUG: Found strings.exe in the current directory
)
call mod_echo Finding Folder...
FOR /F "delims=|" %%I IN ('DIR "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Solidworks*" /B /O:D') DO SET NewestFolder=%%I
if NOT defined NewestFolder (
	call mod_tee ERROR: Solidworks Not Installed /color 0C
	set /a errorct+=1
	call mod_pause
	exit /b 1
)
call mod_echo Found /color 0A
call mod_newline
call mod_echo Finding Shortcut...
FOR /F "delims=|" %%I IN ('DIR "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\%NewestFolder%\" /B /O:D ^| findstr /i /r /c:"SOLIDWORKS [0-9]* x64 Edition\.lnk"') DO SET NewestFile=%%I
if NOT defined NewestFile (
	call mod_tee ERROR: Solidworks Not Installed /color 0C
	set /a errorct+=1
	call mod_pause
	exit /b 1
)
call mod_echo Found /color 0A
call mod_newline
call mod_echo Finding Shortcut Destination...
FOR /F "delims=|" %%I IN ('"%exeloc%" /accepteula "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\%NewestFolder%\%NewestFile%" ^| findstr /i /b /C:"C:"') DO SET Destination=%%I
if NOT defined Destination (
	call mod_tee ERROR: Strings Reading Failed /color 0C
	set /a errorct+=1
	call mod_pause
	exit /b 1
)
call mod_echo Found /color 0A
FOR %%I IN ("%Destination%") DO (
	set DestinationFolder=%%~dpI
	set DestinationFile=%%~nxI
)
call mod_make_shortcut /destination-directory C:\bin\launcher\ /destination-file launcher.exe /arguments %Destination% /shortcut-directory C:\ProgramData\Microsoft\Windows\Start Menu\Programs\%NewestFolder%\ /shortcut-name %NewestFile:.lnk=% /icon-directory %DestinationFolder% /icon-file %DestinationFile%