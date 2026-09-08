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

# Set-StrictMode turns a missing property into a terminating error, and a
# registry value that has never been set is exactly that: absent, not
# empty. Reading one has to be guarded rather than dotted into.
function Get-RegistryValue {
    param(
        [Parameter(Mandatory)] [string] $Path,
        [Parameter(Mandatory)] [string] $Name
    )

    $item = Get-ItemProperty -Path $Path -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $null }
    if ($item.PSObject.Properties.Name -notcontains $Name) { return $null }
    return $item.$Name
}

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
$timeout = Get-RegistryValue -Path $desktopKey -Name 'ScreenSaveTimeOut'
if (-not $timeout) {
    Set-ItemProperty -Path $desktopKey -Name 'ScreenSaveTimeOut' -Value '300'
    Write-Host 'Screen saver timeout was unset; defaulted to 5 minutes.'
}

# The app half of the install: a Start menu entry pointing at the plain
# .exe, so FlipTheClock! can be launched and used like any other program
# rather than only appearing when the machine goes idle.
$startMenu = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'
$shortcut = Join-Path $startMenu 'FlipTheClock!.lnk'
$exePath = Join-Path $destination 'FlipTheClock.exe'

if (Test-Path $exePath) {
    $shell = New-Object -ComObject WScript.Shell
    $link = $shell.CreateShortcut($shortcut)
    $link.TargetPath = $exePath
    $link.WorkingDirectory = $destination
    $link.Description = 'FlipTheClock! - fullscreen flip clock'
    $link.Save()
    Write-Host "Start menu shortcut created."
} else {
    Write-Host "FlipTheClock.exe not found; skipping the Start menu shortcut."
}

# Make the running session pick the change up without a sign-out.
rundll32.exe user32.dll,UpdatePerUserSystemParameters 1, True

Write-Host ''
Write-Host 'Done. FlipTheClock! is installed two ways:'
Write-Host ''
Write-Host '  As an app         search the Start menu for FlipTheClock!, or run'
Write-Host '                    FlipTheClock.exe. Fullscreen clock with a settings'
Write-Host '                    button; clicking does not close it. Alt+F4 to quit.'
Write-Host ''
Write-Host '  As a screen saver starts on its own after the idle time set in'
Write-Host '                    Settings -> Personalization -> Lock screen ->'
Write-Host '                    Screen saver. Any key or mouse move ends it, and it'
Write-Host '                    deliberately has no buttons of its own.'
Write-Host ''
Write-Host 'Run Uninstall.ps1 to remove both.'
