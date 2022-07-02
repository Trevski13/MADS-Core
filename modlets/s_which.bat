setlocal
endlocal & set _path=%~$PATH:1
set s_which=true
if "[%debug%]"=="[true]" echo DEBUG: item: "%_path%" "%~1"
goto :eof