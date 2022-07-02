@echo off
setlocal
call mod_flag_parsing %*
call mod_flag_check /type string /flag message /defaultValue " "
call mod_flag_check /type int /flag time /defaultValue 0

if "%flag_message%" == " " (
	timeout %flag_time%
) else (
	echo %flag_message%
	timeout %flag_time% >nul
)
