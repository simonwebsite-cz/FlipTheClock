FlipTheClock! - Windows screen saver
====================================

A Flutter application is not a single self-contained executable. The
.scr in this folder needs flutter_windows.dll, the plugin DLLs and the
data\ folder sitting next to it, so keep the folder together rather than
copying the .scr out on its own.

Install
-------
Right-click Install.ps1 and choose "Run with PowerShell".

If PowerShell refuses because of the execution policy, open PowerShell in
this folder and run:

    powershell -ExecutionPolicy Bypass -File .\Install.ps1

That copies the app to %LOCALAPPDATA%\FlipTheClock and sets it as your
screen saver. Only your own user account is affected and no
administrator rights are needed.

Uninstall
---------
Run Uninstall.ps1 the same way. It clears the screen saver setting (only
if it still points at FlipTheClock) and deletes the installed folder.

Notes
-----
Windows Settings -> Personalization -> Lock screen -> Screen saver will
show FlipTheClock! as the current screen saver. The dropdown itself only
lists .scr files kept under C:\Windows, so if you pick a different screen
saver there you will not find FlipTheClock! in that list again - re-run
Install.ps1 instead.

You can also just double-click FlipTheClock.scr to run the clock as a
normal fullscreen app, with a settings button in the corner.

Licensed under the MIT License. See LICENSE.
