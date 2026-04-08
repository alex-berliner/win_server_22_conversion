Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
  -Name VisualFXSetting -Value 1

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinAPI {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, IntPtr lpvParam, int fuWinIni);
}
"@

[WinAPI]::SystemParametersInfo(0x002A, 0, [IntPtr]::Zero, 0x03)

$r = [Runtime.InteropServices.Marshal]::StringToHGlobalUni("Environment")
[WinAPI]::SystemParametersInfo(0x1A, 0, $r, 0x03)
