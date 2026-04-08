# Creates a local admin, seeds profile via cmd as that user, then optionally moves profile and symlinks C:\Users\<name> -> new path.

function Compare-SecureStringsEqual {
    param(
        [Security.SecureString] $First,
        [Security.SecureString] $Second
    )
    if ($null -eq $First -or $null -eq $Second) { return $false }
    $b1 = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($First)
    $b2 = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Second)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringUni($b1) -ceq [Runtime.InteropServices.Marshal]::PtrToStringUni($b2)
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b1)
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b2)
    }
}

$UserName    = Read-Host "Enter the Username"
$FullName    = Read-Host "Enter the Full Name"
$Description = Read-Host "Enter a Description for this account"

do {
    $Password = Read-Host -AsSecureString "Enter the password for $UserName"
    $Confirm  = Read-Host -AsSecureString "Confirm the password"
    $match = Compare-SecureStringsEqual -First $Password -Second $Confirm
    if (-not $match) {
        Write-Host "Passwords do not match. Please try again." -ForegroundColor Red
    }
} until ($match)

$userCreated = $false
try {
    New-LocalUser -Name $UserName -Password $Password -FullName $FullName -Description $Description -ErrorAction Stop
    Add-LocalGroupMember -Group 'Administrators' -Member $UserName -ErrorAction Stop
    $userCreated = $true
    Write-Host "`nSuccess: User '$UserName' created and added to Administrators." -ForegroundColor Green
}
catch {
    Write-Host "`nError: Could not create user. $($_.Exception.Message)" -ForegroundColor Yellow
}

if (-not $userCreated) { exit 1 }

$Cred = New-Object System.Management.Automation.PSCredential ($UserName, $Password)
Start-Process "cmd.exe" -ArgumentList "/c exit" -Credential $Cred -WorkingDirectory "C:\"

$profileHome = Join-Path $env:SystemDrive "Users\$UserName"
if (-not (Test-Path -LiteralPath $profileHome)) {
    Write-Warning "Expected profile folder not found: $profileHome (seed may have failed). Skipping move/symlink."
    exit 1
}

$wantRelocate = Read-Host "`n<EXPERIMENTAL>Move user profile folder to another drive/path and symlink $profileHome to it? <EXPERIMENTAL> [y/N]"
if ($wantRelocate -match '^[yY]') {
    $defaultTarget = "F:\Users\$UserName"
    $targetInput = Read-Host "Full path for profile folder (e.g. F:\Users\$UserName). Enter = default $defaultTarget"
    if ([string]::IsNullOrWhiteSpace($targetInput)) {
        $targetPath = $defaultTarget
    } else {
        $targetPath = $targetInput.Trim().TrimEnd('\')
    }

    if (-not [System.IO.Path]::IsPathRooted($targetPath)) {
        Write-Warning "Path must be absolute. Skipping."
    } else {
        $driveRoot = Split-Path -Qualifier $targetPath
        if (-not (Test-Path -LiteralPath $driveRoot)) {
            Write-Warning "Drive '$driveRoot' not available. Skipping."
        } else {
            try {
                $itemHome = Get-Item -LiteralPath $profileHome -Force -ErrorAction Stop
                if ($itemHome.LinkType) {
                    Write-Warning "$profileHome is already a reparse point/symlink. Skipping."
                } else {
                    $targetFull = [System.IO.Path]::GetFullPath($targetPath)
                    $parent = Split-Path -Parent $targetFull
                    if (-not (Test-Path -LiteralPath $parent)) {
                        $null = New-Item -ItemType Directory -Path $parent -Force -ErrorAction Stop
                    }
                    if (Test-Path -LiteralPath $targetFull) {
                        $n = @(Get-ChildItem -LiteralPath $targetFull -Force -ErrorAction SilentlyContinue)
                        if ($n.Count -gt 0) {
                            Write-Warning "Target exists and is not empty: $targetFull Skipping."
                        } else {
                            Remove-Item -LiteralPath $targetFull -Force -Recurse -ErrorAction Stop
                        }
                    }
                    if (-not (Test-Path -LiteralPath $targetFull)) {
                        Write-Host "Close anything running as $UserName, then continue. Copying profile to $targetFull with robocopy (/XJ skips legacy junctions)..." -ForegroundColor Cyan
                        & robocopy.exe $profileHome $targetFull /E /COPYALL /XJ /MOVE /R:2 /W:2 /DCOPY:DAT /NP /NDL /NFL /NJH /NJS /NC /NS # /Q
                        $rc = $LASTEXITCODE
                        if ($rc -ge 8) {
                            throw "robocopy failed (exit $rc). See https://learn.microsoft.com/windows-server/administration/windows-commands/robocopy"
                        }
                        if (Test-Path -LiteralPath $profileHome) {
                            Write-Host "Removing leftover $profileHome ..." -ForegroundColor DarkGray
                            Remove-Item -LiteralPath $profileHome -Recurse -Force -ErrorAction Stop
                        }
                        Write-Host "Creating directory symlink $profileHome -> $targetFull" -ForegroundColor Cyan
                        $null = New-Item -ItemType SymbolicLink -Path $profileHome -Target $targetFull -ErrorAction Stop
                        Write-Host "Done." -ForegroundColor Green
                    }
                }
            }
            catch {
                Write-Warning "Move/symlink failed: $($_.Exception.Message)"
            }
        }
    }
}
