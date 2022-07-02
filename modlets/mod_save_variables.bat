@echo off
del /q %temp%\MADS\cache\vars
for /f "usebackq delims==" %%i IN (`set`) do (
	call echo %%i=%%%%i%%>> %temp%\MADS\cache\vars
)