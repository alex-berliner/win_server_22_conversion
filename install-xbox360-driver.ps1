$Url = "https://catalog.s.download.windowsupdate.com/msdownload/update/driver/drvs/2013/01/20289581_7385d6be1b053a35955a910f11436729a1d4cb56.cab"
$TempDir = "$env:TEMP\8BitDoDriver"
$CabPath = "$env:TEMP\xbox360_driver.cab"

if (!(Test-Path $TempDir)) { New-Item -ItemType Directory -Path $TempDir | Out-Null }

try {
    Invoke-WebRequest -Uri $Url -OutFile $CabPath -ErrorAction Stop
} catch {
    Write-Error "Failed to download driver from Windows Update Catalog."
    exit 1
}

expand.exe $CabPath -F:* $TempDir | Out-Null

$InfPath = Join-Path $TempDir "xusb21.inf"
if (Test-Path $InfPath) {
    $Result = pnputil /add-driver $InfPath /install
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Driver installation failed with exit code $LASTEXITCODE."
        exit $LASTEXITCODE
    }
} else {
    Write-Error "Critical file xusb21.inf missing after extraction."
    exit 1
}

Remove-Item $CabPath -Force -ErrorAction SilentlyContinue
Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue
