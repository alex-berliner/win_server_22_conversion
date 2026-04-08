Set-ItemProperty -Path "HKCU:\Software\Microsoft\ServerManager" -Name "DoNotOpenServerManagerAtLogon" -Value 1

Write-Host "Enabling Windows Audio Service..." -ForegroundColor Cyan
Set-Service -Name "AudioSrv" -StartupType Automatic
Start-Service -Name "AudioSrv"

Write-Host "Enabling Audio Endpoint Builder..." -ForegroundColor Cyan
Set-Service -Name "AudioEndpointBuilder" -StartupType Automatic
Start-Service -Name "AudioEndpointBuilder"

$audioStatus = Get-Service -Name "AudioSrv", "AudioEndpointBuilder"
$audioStatus | Select-Object DisplayName, Status, StartType | Format-Table -AutoSize

Write-Host "Audio services are now active." -ForegroundColor Green
