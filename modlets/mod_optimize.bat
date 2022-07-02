@echo off
setlocal enabledelayedexpansion
if defined flag_file (
	if defined flag_directory (
		if exist "!flag_directory!!flag_file!" (
			for %%f in ("!flag_directory!") do set absolute_directory=%%~dpf 
			echo !absolute_directory! 2> nul | findstr /ic:"%CD%" > nul
			set relative_directory=!flag_directory:%CD%\=!
			if NOT errorlevel 1 (
				if exist "%temp%\MADS\Cache\%scriptname%\!relative_directory!!flag_file!" (
					set flag_directory=%temp%\MADS\Cache\%scriptname%\!relative_directory!
				)
			) else (
				echo File not in local directory
			)
		) else (
			echo Expected file "%flag_directory%%flag_file%" not found
			echo Aborting...
			if "[%pause%]" == "[false]" (
				timeout 15
			) else (
				pause
			)
			exit 1
		)
	) else (
		if not exist "!flag_file!" (
			call s_which !flag_file!
			if "!_path!" == "" (
				echo Expected file "%flag_file%" not found
				echo Aborting...
				if "[%pause%]" == "[false]" (
					timeout 15
				) else (
					pause
				)
				exit 1
			) 
		) else (
			if exist "%temp%\MADS\Cache\%scriptname%\!flag_file!" (
				set flag_directory=%temp%\MADS\Cache\%scriptname%\
			)
		)
	)
) else (
	if defined flag_directory (
		if not exist "!flag_directory!" (
			echo Expected folder "%flag_directory%" not found
			echo Aborting...
			pause
			if "[%pause%]" == "[false]" (
				timeout 15
			) else (
				pause
			)
		)
	)
)
endlocal & set "flag_directory=%flag_directory%" & set "flag_file=%flag_file%"