# Disable requirement to press ctrl+alt+del on login screen (can now just press enter or other)

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableCAD" -Value 1
