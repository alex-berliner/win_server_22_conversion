If you want a leaner daily-driver Windows experience, Windows Server 2022 is a solid option. It is closely related to Windows 10, ships with less default bloat, and has support through Oct 14, 2031.

This repository contains PowerShell scripts to handle common post-install setup tasks.

## Before you start

- Install Windows Server 2022 (ISO: [Microsoft Evaluation Center](https://www.microsoft.com/en-us/evalcenter/download-windows-server-2022)).
- Open an elevated PowerShell session (Run as Administrator).
- Run Windows Update + reboot cycles until no updates remain.
- Execute scripts from this folder.

## Suggested setup flow

1. `create-user-account.ps1`
2. `install-choco.ps1`
3. `install-nvidia.ps1` (if applicable)
4. `server-manager-and-audio.ps1`
5. `visual-effects.ps1`
6. `enable-wsl.ps1` (if needed)
7. `disable-cad-login.ps1` (optional)
8. `install-xbox360-driver.ps1` (optional)

## What each script does

- `create-user-account.ps1`
  - Creates a new local admin account.
  - Can optionally move that user's profile folder to another drive.

- `install-choco.ps1`
  - Installs Chocolatey, so you can install apps and drivers with simple commands.

- `install-nvidia.ps1`
  - Installs NVIDIA display drivers.

- `server-manager-and-audio.ps1`
  - Stops Server Manager from opening every time you sign in.
  - Enables desktop audio support.

- `visual-effects.ps1`
  - Turns on full Windows visual effects and animations.
  - Makes the desktop UI look more like a regular consumer Windows install.

- `enable-wsl.ps1`
  - Enables Windows Subsystem for Linux (WSL), so you can run Linux tools.

- `disable-cad-login.ps1`
  - Lets you sign in without pressing Ctrl+Alt+Del first.

- `install-xbox360-driver.ps1`
  - Adds Xbox 360-style gamepad driver support.
  - Useful for controllers that rely on the Xbox 360 driver stack.

## References

- Windows Server 2022 lifecycle: [Microsoft Lifecycle](https://learn.microsoft.com/en-us/lifecycle/products/windows-server-2022)