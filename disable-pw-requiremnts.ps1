# Get the folder directory where this script is currently running
$ScriptDir = $PSScriptRoot

# If running the lines manually (not from a saved script file), uncomment the line below to use the current working directory instead:
# if ([string]::IsNullOrEmpty($ScriptDir)) { $ScriptDir = Get-Location }

$ConfigFile = Join-Path $ScriptDir "secpol.cfg"

# 1. Export the current security policy to the script's directory
secedit /export /cfg $ConfigFile

# 2. Change PasswordComplexity from 1 (Enabled) to 0 (Disabled)
(Get-Content $ConfigFile) -replace 'PasswordComplexity = 1', 'PasswordComplexity = 0' | Set-Content $ConfigFile

# 3. Import the updated policy back into the system
secedit /configure /db $env:windir\security\local.sdb /cfg $ConfigFile /areas SECURITYPOLICY

# 4. Clean up the temporary file from the script's directory
Remove-Item $ConfigFile