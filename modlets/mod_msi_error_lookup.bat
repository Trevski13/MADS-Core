rem Requires msi_codes.txt
if %debug%==true echo DEBUG: Looking up MSI Error Code %1

call s_which "msi_codes.txt"
if %debug%==true echo DEBUG: Search Results: %_path%
if NOT "%_path%" == "" (
	set "txtloc=%_path%"
	if %debug%==true echo DEBUG: Found msi_codes.txt in path location %_path%
)
if exist msi_codes.txt (
	set "txtloc=msi_codes.txt"
	if %debug%==true echo DEBUG: Found msi_codes.txt in the current directory
)

if not defined txtloc (
	call mod_tee "msi_codes.txt is required for the module and was not found" /color 0E
	call mod_tee "Please include msi_codes.txt and try again" /color 0E
	rem call mod_pause
	exit /b 1
)
for /F "tokens=1,2,*" %%i in (%txtloc%) do (
	if "%%j" == "%~1" (
		call mod_tee "Error Code: %%j" /color 0B
		call mod_tee "%%i" /color 0B
		call mod_tee "%%k" /color 0B
	)
)
if %debug%==true echo DEBUG: Lookup Complete