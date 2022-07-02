Get-Content $env:temp\MADS\cache\vars | Foreach-Object {
	if ($_ -match "^(.*?)=(.*)$") {
		Set-Content "env:\$($matches[1])" $matches[2].Trim()
		#Write-host "env:\$($matches[1])" $matches[2]
	}
}