<#
.SYNOPSIS
    Removes FlipTheClock! as the screen saver and deletes its files.
#>
#Requires -Version 5.1
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$destination = Join-Path $env:LOCALAPPDATA 'FlipTheClock'
$desktopKey = 'HKCU:\Control Panel\Desktop'

# Only clear the setting if it still points at us: the user may have
# picked a different screen saver since installing, and clobbering that
# choice would be rude.
$current = (Get-ItemProperty -Path $desktopKey -Name 'SCRNSAVE.EXE' -ErrorAction SilentlyContinue).'SCRNSAVE.EXE'
if ($current -and $current.StartsWith($destination, [StringComparison]::OrdinalIgnoreCase)) {
    Remove-ItemProperty -Path $desktopKey -Name 'SCRNSAVE.EXE'
    Set-ItemProperty -Path $desktopKey -Name 'ScreenSaveActive' -Value '0'
    Write-Host 'Screen saver setting cleared.'
} elseif ($current) {
    Write-Host "Screen saver is now '$current', not FlipTheClock! - leaving that setting alone."
}

if (Test-Path $destination) {
    Remove-Item -Path $destination -Recurse -Force
    Write-Host "Removed $destination"
} else {
    Write-Host "Nothing installed at $destination"
}

rundll32.exe user32.dll,UpdatePerUserSystemParameters 1, True
Write-Host 'Done.'
