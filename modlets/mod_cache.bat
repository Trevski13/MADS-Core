@echo off
if "[%caching%]" == "[false]" (
	exit /b 0
)
setlocal enabledelayedexpansion
call mod_flag_parsing %*
call mod_flag_check /type file /flag file /defaultValue ""
call mod_flag_check /type string /flag name /defaultValue ""
call mod_flag_check /type dir /flag directory /defaultValue .\

if "[%flag_file%]" == "[true]" set "flag_file="
if "[%flag_name%]" == "[true]" set "flag_name="
if "[%flag_directory%]" == "[true]" set "flag_directory="

if not exist "%temp%\MADS\Cache\%scriptname%\" (
	mkdir "%temp%\MADS\Cache\%scriptname%\"
)

for /f "tokens=3,*" %%n in ('tasklist /fo list /v /fi "imagename eq cmd.exe" ^| find "Window Title"') do (
	set windowtitle=%%n %%o
	if "[!windowtitle!]" == "[Cache: %flag_file%]" (
		echo File is Being Cached, Ignoring...
		exit /b
	)	
)

call s_which fciv.exe
if not "[!_path!]" == "[]" (
	set hash=!_path!
) else (
	set "hash="
)
REM if defined hash (
	REM if NOT exist "%temp%\MADS\cache\SelfTest\" (
		REM mkdir "%temp%\MADS\cache\SelfTest\"
	REM )
	REM if NOT exist "%temp%\MADS\cache\SelfTest\fciv.exe" (
		REM copy  /B /V /Y "!_path!" "%temp%\MADS\cache\SelfTest\fciv.exe" 2>&1 >nul
	REM )
	REM if exist "%temp%\MADS\cache\SelfTest\fciv.exe" (
		REM set hash=%temp%\MADS\cache\SelfTest\fciv.exe
	REM )
REM )

if defined flag_file (
	if defined flag_directory (
		if exist "!flag_directory!!flag_file!" (
			for %%f in ("!flag_directory!") do set absolute_directory=%%~dpf 
			set relative_directory=!flag_directory:%CD%\=!
			echo !absolute_directory! 2> nul | findstr /ic:"%CD%" > nul
			if NOT errorlevel 1 (
				if exist "%temp%\MADS\Cache\%scriptname%\!relative_directory!!flag_file!" (
					for /f usebackq^ skip^=3 %%i in (`%hash% -add "%temp%\MADS\Cache\%scriptname%\!relative_directory!!flag_file!" -sha1`) do set hashvalue1=%%i
					for /f usebackq^ skip^=3 %%i in (`%hash% -add "!flag_directory!!flag_file!" -sha1`) do set hashvalue2=%%i
					if !hashvalue1! == !hashvalue2! (
						echo File Already Cached, Ignoring...
					) else (
						start "Cache: !flag_file!" /min cmd /c echo Copying File... ^& copy  /B /V /Y "!flag_directory!!flag_file!" "%temp%\MADS\Cache\%scriptname%\!relative_directory!!flag_file!" 2^>^&1 ^>nul ^& echo complete ^& timeout /nobreak 2
					)
				) else (
					start "Cache: !flag_file!" /min cmd /c echo Copying File... ^& copy  /B /V /Y "!flag_directory!!flag_file!" "%temp%\MADS\Cache\%scriptname%\!relative_directory!!flag_file!" 2^>^&1 ^>nul ^& echo complete ^& timeout /nobreak 2 
				)
			) else (
				echo File not in local directory
			)
		) else (
			echo Expected file "%flag_directory%%flag_file%" not found
			echo Aborting...
			call mod_pause
			exit 1
		)
	) else (
		if not exist "!flag_file!" (
			call s_which !flag_file!
			if "!_path!" == "" (
				echo Expected file "%flag_file%" not found
				echo Aborting...
				call mod_pause
				exit 1
			) else (
				if exist "%temp%\MADS\Cache\!flag_file!" (
					for /f usebackq^ skip^=3 %%i in (`%hash% -add "%temp%\MADS\Cache\!flag_file!" -sha1`) do set hashvalue1=%%i
					for /f usebackq^ skip^=3 %%i in (`%hash% -add "!_path!" -sha1`) do set hashvalue2=%%i
					if !hashvalue1! == !hashvalue2! (
						echo File Already Cached, Ignoring...
					) else (
						start "Cache: !flag_file!" /min cmd /c echo Copying File... ^& copy  /B /V /Y "!_path!" "%temp%\MADS\Cache\!flag_file!" 2^>^&1 ^>nul ^& echo complete ^& timeout /nobreak 2
					)
				) else (
					start "Cache: !flag_file!" /min cmd /c echo Copying File... ^& copy  /B /V /Y "!_path!" "%temp%\MADS\Cache\!flag_file!" 2^>^&1 ^>nul ^& echo complete ^& timeout /nobreak 2 
				)
			)
		) else (
			if exist "%temp%\MADS\Cache\%scriptname%\!flag_file!" (
				for /f usebackq^ skip^=3 %%i in (`%hash% -add "%temp%\MADS\Cache\%scriptname%\!flag_file!" -sha1`) do set hashvalue1=%%i
				for /f usebackq^ skip^=3 %%i in (`%hash% -add ".\!flag_file!" -sha1`) do set hashvalue2=%%i
				if !hashvalue1! == !hashvalue2! (
					echo File Already Cached, Ignoring...
				) else (
					start "Cache: !flag_file!" /min cmd /c echo Copying File... ^& copy  /B /V /Y ".\!flag_file!" "%temp%\MADS\Cache\%scriptname%\!flag_file!" 2^>^&1 ^>nul ^& echo complete ^& timeout /nobreak 2
				)
			) else (
				start "Cache: !flag_file!" /min cmd /c echo Copying File... ^& copy  /B /V /Y ".\!flag_file!" "%temp%\MADS\Cache\%scriptname%\!flag_file!" 2^>^&1 ^>nul ^& echo complete ^& timeout /nobreak 2
			)
		)
	)
) else (
	if defined flag_directory (
		if not exist "!flag_directory!" (
			echo Expected folder "%flag_directory%" not found
			echo Aborting...
			call mod_pause
			exit 1
		)
	)
)
endlocal
exit /b