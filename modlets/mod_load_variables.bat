@echo off

for /f %%i IN (%temp%\MADS\cache\vars) do (
	set %%i
)