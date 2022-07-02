#requires -version 2
## Get name of this script without extension
$scriptName = $MyInvocation.MyCommand.Name.Substring(0, $MyInvocation.MyCommand.Name.LastIndexOf('.'))

## Set Title
$host.ui.RawUI.WindowTitle = "MADS_core"

## Check if System
if ($env:homepath -eq "\WINDOWS\system32") {
	if ($env:pause -ne "true") {
		$env:pause = "false"
	}
} elseif (-not $env:pause) {
	$env:pause = "true"
}
## Check Operating Mode

if        ($($args[0]) -eq "/room") {
	$mode = "room"
} elseif ($($args[0]) -eq "/direct") {
	$mode = "direct"
} elseif ($($args[0]) -eq "/manual") {
	$mode = "manual"
} else {
	$mode = "manual"
}

## Load Room
if ($mode -eq "room") {
	if (Test-Path room_$($args[1]).ini) {
		Get-Content room_$($args[1]).ini | ForEach-Object {
			$scripts = $_
		}
	} else {
		Write-Host Error Loading Room: room_$($args[1]).ini
		if ($env:pause -ne "false") {
			Write-Host Press any key to continue . . .
			$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
		} else {
			start-sleep -s 15
		}
		exit 1
	}
}
## Load Direct
if ($mode -eq "direct") {
	$scripts = $($args[1])
}

## Log Setup
$scriptName + ":  ================== Script Start ==================" | out-file $env:temp\updater.log -Append -encoding ASCII

$scriptName + ": " + $scriptName + " Version: 1.6 (PS)" | out-file $env:temp\updater.log -Append -encoding ASCII
$scriptName + ": Computer Name: " + $env:computername | out-file $env:temp\updater.log -Append -encoding ASCII
$scriptName + ": IP Addresses: " | out-file $env:temp\updater.log -Append -encoding ASCII
$Networks = Get-WmiObject Win32_NetworkAdapterConfiguration | ? {$_.IPEnabled}
foreach ($Network in $Networks) {
	$scriptName + ": " + $Network.IpAddress[0] | out-file $env:temp\updater.log -Append -encoding ASCII
}
"" | out-file $env:temp\updater.log -Append -encoding ASCII

## Get Directories
$core = ".\"
$modules = ".\"
if (Test-Path settings.ini) {
	$lines = Get-Content settings.ini | Where {$_ -match '^.+\s+=\s+.+$'}
	$lines | ForEach-Object {
		$fields = $_ -split '\s+'
		if ($fields[0] -eq "core"){
			$core = $fields[2]
		}
		elseif ($fields[0] -eq "modules"){
			$modules = $fields[2]
		}
	}
}

## Load Manual
if ($mode -eq "manual") {
	#push-location $modules
	if ($env:pause -eq "false") {
		Write-Host ERROR: Pausing is disabled, unable to prompt for module to Run...
		start-sleep -s 15
		exit 1
	} else {
		$scripts = read-host -prompt "Module to Run (folder)"
	}
}

## Print Directories
Write-Host Core Directory: $core
$scriptName + ": Core Directory: " + $core | out-file $env:temp\updater.log -Append -encoding ASCII
Write-Host Module Directory: $modules
$scriptName + ": Module Directory: " + $modules | out-file $env:temp\updater.log -Append -encoding ASCII
Write-Host
"" | out-file $env:temp\updater.log -Append -encoding ASCII

$scriptName + ": Mode: " + $mode | out-file $env:temp\updater.log -Append -encoding ASCII
if ($mode -eq "room") {
	$scriptName + ": Loaded Room: room_" + $args[1] + ".ini" | out-file $env:temp\updater.log -Append -encoding ASCII
}
$scriptName + ": Scripts: " + $scripts | out-file $env:temp\updater.log -Append -encoding ASCII
Write-Host
"" | out-file $env:temp\updater.log -Append -encoding ASCII

## Set Extension Path
if ($PSVersionTable.PSVersion.Major -lt 3) {
	$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
}
$env:Path += ";" + $env:temp + "\MADS\Cache\modlets" + ";" + $env:temp + "\MADS\Cache\extensions" + ";" + $PSScriptRoot + "\extensions\" + ";" + $PSScriptRoot + "\modlets\"
$extensions = $PSScriptRoot + "\extensions\"
$modlets = $PSScriptRoot + "\modlets\"

## Cache Modlets
if (-Not (Test-Path $env:temp\MADS\Cache) ) {
	New-Item $env:temp\MADS\Cache -itemtype Directory | Out-Null
}
Copy-Item $PSScriptRoot\modlets -Destination $env:temp\MADS\Cache -Force -Recurse

## Cache Extensions
#Copy-Item $PSScriptRoot\extensions -Destination $env:temp\MADS\Cache -Force -Recurse

## Enumerate Extensions
Write-Host Extensions:
$scriptName + ": Extensions: " | out-file $env:temp\updater.log -Append -encoding ASCII
Get-ChildItem ($PSScriptRoot + "\extensions\") | Foreach-Object {
	Write-Host $_.BaseName
	$scriptName + ": " + $_.BaseName | out-file $env:temp\updater.log -Append -encoding ASCII
}
Write-Host
"" | out-file $env:temp\updater.log -Append -encoding ASCII

## Check for window manipulation Powers
$minimizable = $FALSE
if (Get-Command "nircmd.exe" -ErrorAction SilentlyContinue) {
	$minimizable = $TRUE
	$exe = Get-Command nircmd.exe | Select-Object -ExpandProperty Definition
}
Write-Host nircmd?=$minimizable
$scriptName + ": nircmd?=" + $minimizable | out-file $env:temp\updater.log -Append -encoding ASCII
Write-Host
"" | out-file $env:temp\updater.log -Append -encoding ASCII

## manipulate windows if we have the power
if ($minimizable) {
	$result = Start-Process cmd.exe -ArgumentList "/C", $exe, "win", "min", "ititle", "MADS_init" -Wait -PassThru -WindowStyle Minimized
	$result = Start-Process cmd.exe -ArgumentList "/C", $exe, "win", "setsize", "ititle", "MADS_core", "0", "0", "680", "340" -Wait -PassThru -WindowStyle Minimized
}

## set the start time
$starttime = Get-Date
Write-Host Start    : $starttime
$scriptName + ": Start    : " + $starttime | out-file $env:temp\updater.log -Append -encoding ASCII

## More Log Setup
$scriptName + ": " + $scriptName + " start" | out-file $env:temp\updater.log -Append -encoding ASCII
"" | out-file $env:temp\updater.log -Append -encoding ASCII
$errorct = 0

## Run the Pre-Script Process
$result = Start-Process cmd.exe -ArgumentList "/C: exit 1" -wait -PassThru -WindowStyle Hidden
If (Test-Path updater_start\updater_start.ps1) {
	Set-Location updater_start
	$result = Start-Process cmd.exe -ArgumentList "/C powershell.exe -ExecutionPolicy Bypass -File updater_start.ps1" -Wait -PassThru
	Set-Location ..
}
ElseIf (Test-Path updater_start\updater_start.bat) {
	Set-Location updater_start
	$result = Start-Process cmd.exe -ArgumentList "/C updater_start.bat" -Wait -PassThru
	Set-Location ..
}
If ($result.ExitCode -ne 0 ) {
	Write-Host
	Write-Host "errors occurred while trying to execute pre-script process"
	$scriptName + ": errors occurred while trying to execute pre-script process" | out-file $env:temp\updater.log -Append -encoding ASCII
	Write-Host
	"" | out-file $env:temp\updater.log -Append -encoding ASCII
}

Write-Host
"" | out-file $env:temp\updater.log -Append -encoding ASCII

## Main Process
##foreach ($i in $scripts) {
$scripts.split(" ") | ForEach{
	$i = $_
	Write-Host $i  module starting
	$scriptName + ": " + $i + " module starting" | out-file $env:temp\updater.log -Append -encoding ASCII
	## set the start time
	$modulestarttime = Get-Date
	Write-Host Start    : $modulestarttime
	$scriptName + ": Start    : " + $modulestarttime | out-file $env:temp\updater.log -Append -encoding ASCII
	## run module
	$exists = $FALSE
	if (Test-Path $modules$i\$i.ini) {
		if ((Test-Path ($extensions + "Shim.ps1")) -Or (Test-Path ($modlets + "Shim.ps1"))){
			Set-Location $modules$i
			$result = Start-Process cmd.exe -ArgumentList "/C title MADS_module: ", $i,"& Powershell.exe -ExecutionPolicy Bypass -File $((get-command "Shim.ps1" -ErrorAction SilentlyContinue | select-object -first 1).Definition) /module ", $i, "/mode run" -Wait -PassThru
			$exists = $TRUE
			Set-Location (Split-Path $MyInvocation.MyCommand.Path)
		}
		ElseIf ((Test-Path ($extensions + "Shim.bat")) -Or (Test-Path ($modlets + "Shim.bat"))) {
			Set-Location $modules$i
			$result = Start-Process cmd.exe -ArgumentList "/C title MADS_module:", $i,"& Shim.bat /module ", $i, "/mode run" -Wait -PassThru
			$exists = $TRUE
			Set-Location (Split-Path $MyInvocation.MyCommand.Path)
		}
		Else {
			$exists = $FALSE
		}
	}
	if (!$exists){
		If (Test-Path $modules$i\$i.ps1) {
			Set-Location $modules$i
			$result = Start-Process cmd.exe -ArgumentList "/C title MADS_module: ", $i,"& Powershell.exe -ExecutionPolicy Bypass -File",($i + ".ps1") -Wait -PassThru
			$exists = $TRUE
			Set-Location (Split-Path $MyInvocation.MyCommand.Path)
		}
		ElseIf (Test-Path $modules$i\$i.bat){
			Set-Location $modules$i
			$result = Start-Process cmd.exe -ArgumentList "/C title MADS_module: ", $i,"&",($i + ".bat") -Wait -PassThru
			$exists = $TRUE
			Set-Location (Split-Path $MyInvocation.MyCommand.Path)
		}
		Else {
			$exists = $FALSE
		}
	}
	## Set the end time
	$moduleendtime = Get-Date

	## Output Runtime
	Write-Host Finish   : $moduleendtime
	Write-Host Duration : ($moduleendtime - $modulestarttime)

	$scriptName + ": Finish   : " + $moduleendtime | out-file $env:temp\updater.log -Append -encoding ASCII
	$scriptName + ": Duration : " + ($moduleendtime - $modulestarttime) | out-file $env:temp\updater.log -Append -encoding ASCII
	## check for errors
	If (!$exists) {
		Write-Host $i module not found
		$scriptName + ": " + $i + " module not found" | out-file $env:temp\updater.log -Append -encoding ASCII
		$errorct += 1
	}
	ElseIf ($result.ExitCode -eq 0) {
		Write-Host $i module done
		$scriptName + ": " + $i + " module done" | out-file $env:temp\updater.log -Append -encoding ASCII
	}
	Else {
		Write-Host $i module done with $result.ExitCode or more errors
		$scriptName + ": " + $i + " module done with " + $result.ExitCode + " or more errors" | out-file $env:temp\updater.log -Append -encoding ASCII
		$errorct += 1
	}
	Write-Host
	"" | out-file $env:temp\updater.log -Append -encoding ASCII
}
Write-Host complete
$scriptName + ": complete" | out-file $env:temp\updater.log -Append -encoding ASCII

## Set the end time
$endtime = Get-Date

## Output Runtime
Write-Host Finish   : $endtime
Write-Host          ---------------
Write-Host Duration : ($endtime - $starttime)

$scriptName + ": Finish   : " + $endtime | out-file $env:temp\updater.log -Append -encoding ASCII
$scriptName + ":          ---------------" | out-file $env:temp\updater.log -Append -encoding ASCII
$scriptName + ": Duration : " + ($endtime - $starttime) | out-file $env:temp\updater.log -Append -encoding ASCII

##Check for Errors and run the corresponding post-script Process
$result = Start-Process cmd.exe -ArgumentList "/C: exit 1" -wait -PassThru -WindowStyle Hidden
if ($errorct -ne 0) {
	If (Test-Path updater_end_incomplete\updater_end_incomplete.ps1) {
		Set-Location updater_end_incomplete
		$result = Start-Process cmd.exe -ArgumentList "/C powershell.exe -ExecutionPolicy Bypass -File updater_end_incomplete.ps1" -Wait -PassThru
		Set-Location ..
	}
	ElseIf (Test-Path updater_end_incomplete\updater_end_incomplete.bat) {
		Set-Location updater_end_incomplete
		$result = Start-Process cmd.exe -ArgumentList "/C updater_end_incomplete.bat" -Wait -PassThru
		Set-Location ..
	}
	If ($result.ExitCode -ne 0 ) {
		Write-Host
		Write-Host "errors occurred while trying to execute post-script process"
		$scriptName + ": errors occurred while trying to execute post-script-script process" | out-file $env:temp\updater.log -Append -encoding ASCII
		Write-Host
	}
	Write-Host errors have occured in $errorct modules, please check the log file
	#write to log
	if ($env:pause -eq "true") {
		$opt =  $host.UI.PromptForChoice("" , "View Log?" , [System.Management.Automation.Host.ChoiceDescription[]] @("&Yes", "&No"),1)
		if ($opt -eq 0) {
			$result = Start-Process notepad++.exe -ArgumentList $env:temp\updater.log,"-n999999" -PassThru
		}
	} else {
		start-sleep -s 15
	}
}
Else {
	If (Test-Path updater_end_complete\updater_end_complete.ps1) {
		Set-Location updater_end_complete
		$result = Start-Process cmd.exe -ArgumentList "/C powershell.exe -ExecutionPolicy Bypass -File updater_end_complete.ps1" -Wait -PassThru
		Set-Location ..
	}
	ElseIf (Test-Path updater_end_complete\updater_end_complete.bat) {
		Set-Location updater_end_complete
		$result = Start-Process cmd.exe -ArgumentList "/C updater_end_complete.bat" -Wait -PassThru
		Set-Location ..
	}
	If ($result.ExitCode -ne 0 ) {
		Write-Host
		Write-Host "errors occurred while trying to execute post-script process"
		$scriptName + ": errors occurred while trying to execute post-script-script process" | out-file $env:temp\updater.log -Append -encoding ASCII
		Write-Host
		"" | out-file $env:temp\updater.log -Append -encoding ASCII
	}
}

$scriptName + ": =================== Script End ===================" | out-file $env:temp\updater.log -Append -encoding ASCII
"`n" | out-file $env:temp\updater.log -Append -encoding ASCII

Remove-Item $env:temp\MADS\Cache\modlets\*

## manipulate windows if we have the power
if ($minimizable) {
	$result = Start-Process cmd.exe -ArgumentList "/C", $exe, "win", "min", "ititle", "MADS_core" -Wait -PassThru -WindowStyle Minimized
	$result = Start-Process cmd.exe -ArgumentList "/C", $exe, "win", "normal", "ititle", "MADS_init" -Wait -PassThru -WindowStyle Minimized
}

exit