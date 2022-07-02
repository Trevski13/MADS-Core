@echo off
setlocal enabledelayedexpansion
call mod_flag_parsing %*
call mod_flag_check /type file /flag file /defaultValue ""
call mod_flag_check /type string /flag name /defaultValue ""
call mod_flag_check /type dir /flag directory /defaultValue .\

if "[%flag_file%]" == "[true]" set "flag_file="
if "[%flag_name%]" == "[true]" set "flag_name="
if "[%flag_directory%]" == "[true]" set "flag_directory="

:caching
for /f "tokens=3,*" %%n in ('tasklist /fo list /v /fi "imagename eq cmd.exe" ^| find "Window Title"') do (
	set windowtitle=%%n %%o
	if "[!windowtitle!]" == "[Cache: %flag_file%]" (
		timeout /nobreak 2 > nul
		goto :caching
	)	
)

if defined flag_file (
	if defined flag_directory (
		if not exist "!flag_directory!!flag_file!" (
			echo Expected file "%flag_directory%%flag_file%" not found
			echo Aborting...
			pause
			exit 1
		)
	) else (
		if not exist "!flag_file!" (
			call s_which "!flag_file!"
			if "!_path!" == "" (
				echo Expected file "%flag_file%" not found
				echo Aborting...
				pause
				exit 1
			)
		)
	)
) else (
	if defined flag_directory (
		if not exist "!flag_directory!" (
			echo Expected folder "%flag_directory%" not found
			echo Aborting...
			pause
			exit 1
		)
	)
)
endlocal
exit /b