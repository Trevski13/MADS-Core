#requires -version 2
## increment the depth counter (aka how manytimes we've called ourselves), as an abnormal increase in this may indicate a dependency loop.
if (!$env:depth) {
	Write-Host Self Check
	Write-Host Loading...
	$env:depth=1
	$env:builtin=""
	if (test-path ($env:temp + "\MADS\cache\SelfTest\builtin.ini")) {
		$env:builtin = [IO.File]::ReadAllLines($env:temp + "\MADS\cache\SelfTest\builtin.ini")
	} else {
		$env:builtin=""
		(cmd /c help) | out-string -stream | foreach-object { if ($_.split(" ")[0] -cmatch "^[A-Z]{2,}$") { $env:builtin += " " + $_.split(" ")[0]}}
	}
} else {
	$env:depth=$env:depth/1 + 1
}
#write-host depth: $env:depth
if ($env:depth -eq 1) {
	##Load Checked
	if (test-path ($env:temp + "\MADS\cache\SelfTest\checked.ini")) {
		$env:checked = [IO.File]::ReadAllLines($env:temp + "\MADS\cache\SelfTest\checked.ini")
	}
	##TODO: check for spinner
	if ($((get-command "mod_spinner.bat" -ErrorAction SilentlyContinue | select-object -first 1).Definition)) {
		$env:spinnerenabled="true"
	} else {
		$env:spinnerenabled="false"
	}
	#write-host spinner: $env:spinnerenabled
	##load hashing
	if ($((get-command "fciv.exe" -ErrorAction SilentlyContinue | select-object -first 1).Definition)) {
		$env:hash = $((get-command "fciv.exe" -ErrorAction SilentlyContinue | select-object -first 1).Definition)
	}
	if ($env:hash) {
		if (-Not (Test-Path $env:temp\MADS\Cache\SelfTest) ) {
			New-Item $env:temp\MADS\Cache\SelfTest -itemtype Directory | Out-Null
		}
		if (-Not (Test-Path $env:temp\MADS\Cache\SelfTest\fciv.exe) ) {
			Copy-Item $env:hash -Destination $env:temp\MADS\Cache\SelfTest -Force
		}
		if ((Test-Path $env:temp\MADS\Cache\SelfTest\fciv.exe) ) {
			$env:hash = $env:temp + "\MADS\Cache\SelfTest\fciv.exe"
		}
	}
	#Write-Host Hash:  $env:hash
	Write-Host Loaded
	Write-Host Running...
} else {
	## TODO: debugging comment
}

if ($env:depth -ge 10) {
	Write-Host Recursion limit reached, please check scripts for dependency loops
	if ($env:pause -eq "false") {
		Write-Host Press any key to continue . . .
		$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	} else {
		start-sleep -s 15
	}
	exit 1
}

if (!$args[0]) {
	Write-Host An Error Has Occured while attempting to run the selftest
	Write-Host Please make sure the script is formated properly and run again
	Write-Host ERROR: input is empty
	if ($env:pause -eq "false") {
		Write-Host Press any key to continue . . .
		$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	} else {
		start-sleep -s 15
	}
	exit 1
}

##TODO: Load Requirements if exist

if (Get-Command $args[0] -ErrorAction SilentlyContinue) {
	Get-Content $args[0] | where-object {$_ -match "^((&)|(cmd \/Q \/C call) mod_.+)|(## Requires .*)$"} | ForEach-Object {
		## TODO: Spinner stuff
		#if lroo
		#Write-host $_
		if ($_ -match "^& mod_.+$") {
			#Write-host PS Script
			#($_ -split " ")[1]
			if (-Not (Get-Command ($_ -split " ")[1] -ErrorAction SilentlyContinue)) {
				if (-Not (Test-Path ($_ -split " ")[1] -ErrorAction SilentlyContinue)) {
					Write-Host ($_ -split " ")[1] was not found, please check the script for typos
					Write-Host or the modlet directory for missing modlets
					Write-Host ERROR: ($_ -split " ")[1] on line $_ of $args[0] doesn''t exist
					if ($env:pause -eq "false") {
						Write-Host Press any key to continue . . .
						$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
					} else {
						start-sleep -s 15
					}
					exit 1
				}
			}
			if (test-path (($_ -split " ")[1] + ".ps1")) {
				& mod_SelfTest (($_ -split " ")[1] + ".ps1")
			} elseif (get-command (($_ -split " ")[1] + ".ps1") -ErrorAction SilentlyContinue) {
				& mod_SelfTest  $((get-command (($_ -split " ")[1] + ".ps1") -ErrorAction SilentlyContinue | select-object -first 1).Definition)
			} else {
				write-host ERROR: unable to locate item
			}
		} elseif ($_ -match "^cmd \/Q \/C call mod_.+$") {
			#Write-host Batch Script
			#($_ -split " ")[4]
			if (-Not (Get-Command ($_ -split " ")[4] -ErrorAction SilentlyContinue)) {
				if (-Not (Test-Path ($_ -split " ")[4] -ErrorAction SilentlyContinue)) {
					Write-Host ($_ -split " ")[4] was not found, please check the script for typos
					Write-Host or the modlet directory for missing modlets
					Write-Host ERROR: ($_ -split " ")[4] on line $_ of $args[0] doesn`'t exist
					#`'
					if ($env:pause -eq "false") {
						Write-Host Press any key to continue . . .
						$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
					} else {
						start-sleep -s 15
					}
					exit 1
				}
			}
			if (test-path (($_ -split " ")[4] + ".bat")) {
				cmd /Q /C call mod_SelfTest (($_ -split " ")[4] + ".bat") `& call mod_save_variables; if (!$?) {exit $lastexitcode} else {& "mod_load_variables.ps1"}
			} elseif (get-command (($_ -split " ")[4] + ".bat") -ErrorAction SilentlyContinue) {
				cmd /Q /C call mod_SelfTest $((get-command (($_ -split " ")[4] + ".bat") -ErrorAction SilentlyContinue | select-object -first 1).Definition) `& call mod_save_variables; if (!$?) {exit $lastexitcode} else {& "mod_load_variables.ps1"}
			} else {
				write-host ERROR: unable to locate item
			}
		} elseif ($_ -match "^## Requires .*$") {
			#Write-host Requires
			#($_ -split " ")[2]l
			if (-Not (Get-Command ($_ -split " ")[2] -ErrorAction SilentlyContinue)) {
				if (-Not (Test-Path ($_ -split " ")[2] -ErrorAction SilentlyContinue)) {
					Write-Host ($_ -split " ")[2] was not found, please check the script for typos
					Write-Host or the extensions directory for missing components
					Write-Host ERROR: ($_ -split " ")[2] on line $_ of $args[0] doesn`'t exist
					#`'
					if ($env:pause -eq "false") {
						Write-Host Press any key to continue . . .
						$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
					} else {
						start-sleep -s 15
					}
					exit 1
				}
			}
		} else {
			Write-Host An Error Has Occured while attempting to run the selftest
			Write-Host Please make sure the script is formated properly and run again
			Write-Host ERROR: Regex Mismatch
			Write-Host DETAIL: $_ was unexpected
			if ($env:pause -eq "false") {
				Write-Host Press any key to continue . . .
				$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
			} else {
				start-sleep -s 15
			}
			exit 1
		}
	}
} else {
	Write-Host An Error Has Occured while attempting to run the selftest
	Write-Host Please make sure the script is formated properly and run again
	Write-Host ERROR: Missing Item
	Write-Host DETAIL: $args[0] does not exist
	if ($env:pause -eq "false") {
		Write-Host Press any key to continue . . .
		$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	} else {
		start-sleep -s 15
	}
	exit 1
}
if ($env:depth -eq 1) {
	Write-Host The Self Check Has Passed
	##TODO: Save checked and builtin
	$env:checked | out-file ($env:temp + "\MADS\cache\SelfTest\checked.ini") -encoding ASCII
	$env:builtin | out-file ($env:temp + "\MADS\cache\SelfTest\builtin.ini") -encoding ASCII
}
##TODO: Save requirements
$env:depth=$env:depth/1 - 1
$env:checked+= " " + $args[0]
