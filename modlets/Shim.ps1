#requires -version 2

##Initialization
Write-Host Shim
Write-Host Initializing...
if (Get-Command "nircmd.exe" -ErrorAction SilentlyContinue) {
	$result = Start-Process cmd.exe -ArgumentList "/C", (Get-Command nircmd.exe | Select-Object -ExpandProperty Definition), "win", "setsize", "ititle", "MADS_module", "680", "0", "680", "340" -Wait -PassThru -WindowStyle Minimized
}

if (Get-Command "mod_flag_parsing.bat" -ErrorAction SilentlyContinue) {
	if ( (Get-Command "mod_save_variables.bat" -ErrorAction SilentlyContinue) `
	-AND (Get-Command "mod_load_variables.ps1" -ErrorAction SilentlyContinue)) {
		cmd /C call mod_flag_parsing $args `& call mod_save_variables; if (!$?) {exit $lastexitcode} else {& "mod_load_variables.ps1"}
	} else {
		Write-Host Initialization failed because mod_save_variables or mod_load_variables wasn`'t found
		#'
		Write-Host Press any key to continue . . .
		$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
		exit 1
	}
} else {
	Write-Host Initialization failed because mod_flag_check wasn`'t found
	#'
	Write-Host Press any key to continue . . .
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	exit 1
}
if (Get-Command "mod_flag_check.bat" -ErrorAction SilentlyContinue) {
	cmd /C call mod_flag_check /type string /flag module `& call mod_save_variables; if (!$?) {exit $lastexitcode} else {& "mod_load_variables.ps1"}
	cmd /C call mod_flag_check /type enum /flag mode /acceptedValues cache run /defaultValue run `& call mod_save_variables; if (!$?) {exit $lastexitcode} else {& "mod_load_variables.ps1"}
} else {
	Write-Host Initialization failed because mod_flag_check wasn`'t found
	#'
	Write-Host Press any key to continue . . .
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	exit 1
}

$hash = (Get-Command "fciv.exe" -ErrorAction SilentlyContinue).Source
<# if ($hash) {
	Write-Host fciv found
} else {
	Write-Host fciv not found
} #>

if (!(test-path ($env:temp + "\MADS\cache\built"))) {
	New-Item $env:temp\MADS\Cache\built -itemtype Directory | Out-Null
}
<# if (test-path $env:flag_module) {
	Push-Location -Path $env:flag_module
} else {
	Write-Host Internal Error: Couldn`'t find module: $env:flag_module in 
	#'
	Write-Host Press any key to continue . . .
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	exit 1
} #>
if (!(Test-path ($env:flag_module + ".ini"))) {
	Write-Host Internal Error: Couldn`'t find ini file in: $env:flag_module
	#'
	Write-Host Press any key to continue . . .
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	exit 1
}


$requiresBuilding = $false
if (!(test-path ($env:temp + "\MADS\cache\built\" + $env:flag_module + ".ps1"))) {
	$requiresBuilding = $true
} else {
	#TODO: HASH Verification
	$requiresBuilding = $true
}

if (!($env:temp + "\MADS\cache\built\modulelocation")) {
	push-location -path ..\
	$(get-location).path | out-file $env:temp\MADS\cache\built\modulelocation -encoding ASCII
	pop-location
}

if ($requiresBuilding) {
	Remove-item ($env:temp + "\MADS\cache\built\" + $env:flag_module + ".ps1") -ErrorAction SilentlyContinue
	Write-Host Building...
	$(
		"`$env:errorct=1"
		"if (Test-Path `$env:temp\MADS\cache\built\modulelocation) {"
		"	Get-Content `$env:temp\MADS\cache\built\modulelocation | ForEach-Object {"
		"		`$env:modulelocation = `$_"
		"	}"
		"}"
		"cmd /Q /C call mod_header `"`$env:modulelocation\$env:flag_module\$env:flag_module.ps1`" `$args ```& call mod_save_variables; if (!`$?) {exit `$lastexitcode} else {& `"mod_load_variables.ps1`"}"
		"if (`$env:errorct -ne 0) {
			write-host The Script did not start correctly
			`$x = `$host.UI.RawUI.ReadKey(`"NoEcho,IncludeKeyDown`")
			exit 1
		}"
		"`#Begin Script"
		foreach($line in Get-Content ($env:flag_module + ".ini")) {
			if (Get-Command ("mod_" + ($line.Split(" ")[0]) + ".ps1") -ErrorAction SilentlyContinue) {
				"& mod_$line"
			} else {
				"cmd /Q /C call mod_$($line -replace "'","``'" -replace "\(","``(" -replace "\)","``)") ```& call mod_save_variables; if (!`$?) {exit `$lastexitcode} else {& `"mod_load_variables.ps1`"}"
			}
		}
		"`#End Script"
		"cmd /q /c mod_footer`; exit `$lastexitcode"
		"write-host The Script did not terminate correctly"
		"Write-Host Press any key to continue . . ."
		"`$x = `$host.UI.RawUI.ReadKey(`"NoEcho,IncludeKeyDown`")"
		"exit 1
		"
	) | out-file ($env:temp + "\MADS\cache\built\" + $env:flag_module + ".ps1") -Append -encoding ASCII
}

#TODO: HASH Testing

if ($true) {
	Write-Host Testing...
	Write-Host
	if (Get-Command mod_SelfTest.ps1 -ErrorAction SilentlyContinue) {
		& mod_selfTest ($env:temp + "\MADS\cache\built\" + $env:flag_module + ".ps1")
	} else {
		Write-Host Internal Error: Couldn`'t find SelfTest
		#'
		Write-Host Press any key to continue . . .
		$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
		exit 1
	}
	## TODO: hash save
}
#$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
if ($env:flag_mode -eq "run") {
	& ($env:temp + "\MADS\cache\built\" + $env:flag_module + ".ps1")
}
exit $lastexitcode