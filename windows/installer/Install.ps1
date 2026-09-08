<#
.SYNOPSIS
    Installs FlipTheClock! as the current user's Windows screen saver.

.DESCRIPTION
    A Flutter application is not a single self-contained executable: the
    .scr needs flutter_windows.dll, the plugin DLLs and the data\ folder
    sitting beside it. That rules out the usual "drop one .scr into
    System32" install, so this copies the whole payload into
    %LOCALAPPDATA%\FlipTheClock and points the screen saver setting at
    the full path instead.

    Only HKCU is touched, so this needs no administrator rights and
    affects only the user who runs it.
#>
#Requires -Version 5.1
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$source = $PSScriptRoot
$scrName = 'FlipTheClock.scr'
$destination = Join-Path $env:LOCALAPPDATA 'FlipTheClock'
$desktopKey = 'HKCU:\Control Panel\Desktop'

if (-not (Test-Path (Join-Path $source $scrName))) {
    throw "$scrName not found next to this script. Run Install.ps1 from the folder you extracted the release zip into."
}

Write-Host "Installing FlipTheClock! to $destination"

# Robocopy would be tidier but its exit codes fight $ErrorActionPreference.
if (Test-Path $destination) {
    Remove-Item -Path $destination -Recurse -Force
}
New-Item -ItemType Directory -Path $destination -Force | Out-Null
Copy-Item -Path (Join-Path $source '*') -Destination $destination -Recurse -Force

$scrPath = Join-Path $destination $scrName

# The screen saver picker in Settings only enumerates .scr files under
# %SystemRoot%, but the setting itself accepts any absolute path, and
# Windows launches it the same way.
Set-ItemProperty -Path $desktopKey -Name 'SCRNSAVE.EXE' -Value $scrPath
Set-ItemProperty -Path $desktopKey -Name 'ScreenSaveActive' -Value '1'

# Leave an existing timeout alone; only supply one if the user has never
# set it, so we don't silently change how long their machine waits.
$timeout = (Get-ItemProperty -Path $desktopKey -Name 'ScreenSaveTimeOut' -ErrorAction SilentlyContinue).'ScreenSaveTimeOut'
if (-not $timeout) {
    Set-ItemProperty -Path $desktopKey -Name 'ScreenSaveTimeOut' -Value '300'
    Write-Host 'Screen saver timeout was unset; defaulted to 5 minutes.'
}

# Make the running session pick the change up without a sign-out.
rundll32.exe user32.dll,UpdatePerUserSystemParameters 1, True

Write-Host ''
Write-Host 'Done. FlipTheClock! is now your screen saver.'
Write-Host 'Check it under Settings -> Personalization -> Lock screen -> Screen saver.'
Write-Host 'Run Uninstall.ps1 to remove it.'
