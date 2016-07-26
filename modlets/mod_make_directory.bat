call mod_echo Creating Directory %1...
call mod_log Creating Directory %1
if NOT exist %1 (
	mkdir %1 2>&1 >nul
	if ERRORLEVEL 1 (
		call mod_tee Error: %errorlevel% /color 0C
		set /a errorct+=1
		pause
	) else (
		call mod_tee Directory Created Sucessfully /color 0A
	)
) else (
	call mod_tee Directory Already Exists, Ignoring /color 0E
)