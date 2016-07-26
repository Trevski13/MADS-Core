@echo off
call mod_flag_parsing %*

call mod_echo Flags:
for /f "usebackq delims==" %%i IN (`set ^| findstr /i /c:"flag_"`) do (
	echo/ > nul & call echo %%i=%%%%i%%
)
call mod_pause