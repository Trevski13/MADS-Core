@echo off

REM This modlet installs a program from an MSI file

setlocal enabledelayedexpansion

call mod_flag_parsing %*
call mod_help "%~dpnx0" && exit /b
call mod_optimize

call mod_flag_check /type file /flag file
call mod_flag_check /type dir /flag directory /defaultValue .\
call mod_flag_check /type string /flag name
call mod_flag_check /type boolean /flag passive /defaultValue true
call mod_flag_check /type string /flag args /defaultValue " "


REM if exist %temp%\MADS\cache\%scriptname%\ (
	REM pushd %temp%\MADS\cache\%scriptname%\
REM )
if "[%debug%]"=="[true]" echo DEBUG: setting Passive Status
if %flag_passive%==true (
	set "passive=/passive"
) else (
	set "passive="
)
if "[%debug%]"=="[true]" echo DEBUG: done Setting Passive Status
call mod_echo Installing %flag_name%...
call mod_log Installing %flag_name% via %flag_file% with args: %flag_args%
if "[%debug%]"=="[true]" echo DEBUG: Installing...
start "" /wait msiexec /i "%flag_directory%%flag_file%" %passive% %flag_args%
call mod_error /error %errorlevel% /alternate-successes "3010,1605"
REM if exist %temp%\MADS\cache\%scriptname%\ (
	REM popd
REM )
endlocal & set errorct=%errorct%
exit /b