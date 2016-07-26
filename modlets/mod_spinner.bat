@echo off
setlocal EnableDelayedExpansion

if "[%~1]"=="[/clear]" (
	echo/            
	exit /b
)

if "[%~1]"=="[/speedhack]" (
	if "[%debug%]"=="[true]" echo DEBUG: enabling speed hack
	set flag_title=false
	set flag_inline=true
) else (
	call mod_flag_parsing %*
	call mod_flag_check /type boolean /flag title /defaultValue false
	call mod_flag_check /type boolean /flag inline /defaultValue true
)
if "[%debug%]"=="[true]" echo DEBUG: /title=%flag_title%
if "[%debug%]"=="[true]" echo DEBUG: /inline=%flag_inline%
if NOT defined CR (
	for /f %%a in ('copy /Z "%~dpf0" nul') do set "CR=%%a"
)
set /a "spinner=(spinner + 1) %% 4"
set spinChars=\^|/-
if %flag_inline%==true (
	if "[%debug%]"=="[true]" echo DEBUG: Outputting Spinner value
	<nul set /p ".=Processing !spinChars:~%spinner%,1!!CR!"
	if "[%debug%]"=="[true]" echo.
)
if %flag_title%==true (
	if "[%debug%]"=="[true]" echo DEBUG: setting title
	if "!spinChars:~%spinner%,1!" == "-" (
		title Processing --
	) else (
		if "!spinChars:~%spinner%,1!" == ^| (
			title Processing  ^|
		) else (
			title Processing  !spinChars:~%spinner%,1!
		)
	)
)
if "[%debug%]"=="[true]" echo DEBUG: Spinner Done
endlocal & set /a spinner=%spinner% & set "CR=%CR%"
exit /b