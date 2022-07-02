@echo off
start "" /wait %* <nul
call mod_error /error:%errorlevel% /alternate-successes 3010
exit /b