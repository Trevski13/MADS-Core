@echo off
rem set defaults
set /a errorct=0
set "logfile=%temp%\updater.log"
set "scriptName=%~n1"
set "preload=false"
if not defined debug (
	set debug=false
)

rem manipulate windows if we have the power
call s_which nircmd.exe 2>&1 > nul
if not "%_path%" == "" (
	nircmd win setsize ititle MADS_module 0 340 680 340
)

rem mess with commandline inputs so we can pass them on to be parsed
shift
set argc=0
if "[%debug%]"=="[true]" echo DEBUG: Processing Arguments...
:loop
if "[%debug%]"=="[true]" echo DEBUG: argument "%~1"
if "[%~1]"=="[]" goto break
set /a argc+=1
set "argv_%argc%=%~1"
if defined argp (
	set "argp=%argp% %%argv_%argc%%%"
) else (
	set "argp=%%argv_%argc%%%"
	rem echo. >nul & call set "argp=%%%%%%%%argv_%%%%argc%%%%%%%%%%%%"
	rem "argp=%%argv_%argc%%%"
)
shift
goto loop
:break
if "[%debug%]"=="[true]" echo DEBUG: ARGP=%argp%
if "[%debug%]"=="[true]" call echo DEBUG: ARGP value=%argp%
rem pass the arguments on to the parser
echo. > nul & call (
	call mod_flag_parsing %argp%
)
rem set values from flags
if defined flag_debug (
	set debug=%flag_debug%
)
if defined flag_preload (
	set preload=%flag_preload%
)
rem change directories and clear screen
if NOT "[%~0]" == "[]" (
	cd /d %~dp1
)
if "[%debug%]"=="[true]" ( pause )
cls
if "[%debug%]"=="[true]" echo DEBUG: logfile is %logfile%
if "[%debug%]"=="[true]" echo DEBUG: Scriptname is %scriptName%
if "[%debug%]"=="[true]" echo DEBUG: Current Directory is %CD%