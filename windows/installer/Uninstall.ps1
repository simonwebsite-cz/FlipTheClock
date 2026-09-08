<#
.SYNOPSIS
    Removes FlipTheClock! as the screen saver and deletes its files.
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

$destination = Join-Path $env:LOCALAPPDATA 'FlipTheClock'
$desktopKey = 'HKCU:\Control Panel\Desktop'

# Only clear the setting if it still points at us: the user may have
# picked a different screen saver since installing, and clobbering that
# choice would be rude.
$current = Get-RegistryValue -Path $desktopKey -Name 'SCRNSAVE.EXE'
if ($current -and $current.StartsWith($destination, [StringComparison]::OrdinalIgnoreCase)) {
    Remove-ItemProperty -Path $desktopKey -Name 'SCRNSAVE.EXE'
    Set-ItemProperty -Path $desktopKey -Name 'ScreenSaveActive' -Value '0'
    Write-Host 'Screen saver setting cleared.'
} elseif ($current) {
    Write-Host "Screen saver is now '$current', not FlipTheClock! - leaving that setting alone."
}

$shortcut = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\FlipTheClock!.lnk'
if (Test-Path $shortcut) {
    Remove-Item -Path $shortcut -Force
    Write-Host 'Start menu shortcut removed.'
}

if (Test-Path $destination) {
    Remove-Item -Path $destination -Recurse -Force
    Write-Host "Removed $destination"
} else {
    Write-Host "Nothing installed at $destination"
}

rundll32.exe user32.dll,UpdatePerUserSystemParameters 1, True
Write-Host 'Done.'
