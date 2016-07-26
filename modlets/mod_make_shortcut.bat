@echo off
rem Requires nircmd.exe
call mod_flag_parsing %*
call mod_flag_check /type dir /flag destination-directory
call mod_flag_check /type file /flag destination-file
call mod_flag_check /type dir /flag shortcut-directory
call mod_flag_check /type file /flag shortcut-name
call mod_flag_check /type string /flag arguments /defaultValue " "
call mod_flag_check /type dir /flag icon-directory /defaultValue " "
call mod_flag_check /type file /flag icon-file /defaultValue " "
call mod_flag_check /type int /flag icon-number /defaultValue " "

call s_which nircmd.exe
if NOT "!_path!" == "" (
	set "exeloc=nircmd.exe"
	if %debug%==true echo DEBUG: Found nircmd.exe in path location !_path!
)
if exist nircmd.exe (
	set "exeloc=nircmd.exe"
		if %debug%==true echo DEBUG: Found nircmd.eze in the current directory
)
call mod_tee Making New Link
call mod_log Link is located in "%flag_shortcut-directory%%flag_shortcut-name%" linking to "%flag_destination-directory%%flag_destination-file%" with arguments "%flag_arguments%" with icon %flag_icon-number% in "%flag_icon-directory%%flag_icon-file%"
"%exeloc%" shortcut "%flag_destination-directory%%flag_destination-file%" "%flag_shortcut-directory%" "%flag_shortcut-name%" "%flag_arguments%" "%flag_icon-directory%%flag_icon-file%" %flag_icon-number%
if ERRORLEVEL 1 (
	call mod_tee Error:  %errorlevel% /color 0C
	set /a errorct+=1
	pause
) else (
	if exist "%flag_shortcut-directory%%flag_shortcut-name%.lnk" (
		call mod_tee "Created Sucessfully" /color 0A
	) else (
		call mod_tee Error:  File Not Created /color 0C
		set /a errorct+=1
		pause
	)
)
echo "%flag_shortcut-directory%%flag_shortcut-name%.lnk"
rem mod_make_shortcut /destination-directory %windir%\System32\ /destination-file notepad.exe /shortcut-directory %temp%\ /shortcut-name test /icon-directory %windir%\System32\ /icon-file cmd.exe /icon-number 1