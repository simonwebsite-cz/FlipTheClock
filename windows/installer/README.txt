FlipTheClock! for Windows
=========================

This folder is both a normal app and a screen saver. They are the same
program: which one you get depends only on how it is started.

  FlipTheClock.exe    The app. A fullscreen clock with a settings button
                      in the corner. Clicking does not close it. Quit
                      with Alt+F4.

  FlipTheClock.scr    The screen saver. Windows starts it after the idle
                      time you choose, and any key or mouse movement ends
                      it. It has no buttons on purpose: on a screen saver
                      the first click has to close it, so there is nothing
                      it could usefully show.

A Flutter application is not a single self-contained executable. Both
files need flutter_windows.dll, the plugin DLLs and the data\ folder
beside them, so keep this folder together rather than copying one file
out on its own.

Install
-------
Right-click Install.ps1 and choose "Run with PowerShell".

If PowerShell refuses because of the execution policy, open PowerShell in
this folder and run:

    powershell -ExecutionPolicy Bypass -File .\Install.ps1

That copies everything to %LOCALAPPDATA%\FlipTheClock, adds a Start menu
entry for the app, and registers the screen saver. Only your own user
account is affected and no administrator rights are needed.

You do not have to install it at all: FlipTheClock.exe runs fine straight
from this folder.

Using it
--------
As an app          Search the Start menu for FlipTheClock!, or double-click
                   FlipTheClock.exe.

As a screen saver  It starts by itself once the machine has been idle.
                   Change the wait under Settings -> Personalization ->
                   Lock screen -> Screen saver.

Settings           Open the app and use the button in the top-right
                   corner, or press "Settings" in the Windows screen saver
                   dialog. There is one set of settings and both share it:
                   12/24 hour, seconds, date, colour theme, digit size and
                   font weight.

Uninstall
---------
Run Uninstall.ps1 the same way. It removes the Start menu entry, clears
the screen saver setting (only if it still points at FlipTheClock!) and
deletes the installed folder.

Notes
-----
Right-clicking FlipTheClock.scr gives you Windows' own menu for screen
savers, where the labels do not match what the entries do:

    "Open" (or a double-click)  runs the screen saver, not the app
    "Install"                   only opens the screen saver settings dialog
    "Configure"                 opens FlipTheClock!'s settings

Use FlipTheClock.exe when you want the app; that is what it is there for.

The screen saver dropdown in Windows Settings lists only .scr files kept
under C:\Windows. FlipTheClock! is not there, because it needs its DLLs
next to it. It still shows as the selected screen saver, but if you pick a
different one you will not find FlipTheClock! in that list again - re-run
Install.ps1 instead.

Licensed under the MIT License. See LICENSE.
