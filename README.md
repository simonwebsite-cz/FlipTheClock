# FlipTheClock

An open-source flip-clock screensaver and app for Windows, Android, and macOS. Not affiliated with Fliqlo — see [legal/TRADEMARK_NOTICE.md](legal/TRADEMARK_NOTICE.md).

**Website: [tichysimon.cz/FlipTheClock](https://www.tichysimon.cz/FlipTheClock/)** — downloads for every platform, with a live flip clock on the page.

100% offline. No accounts, no analytics, no ads, no network permission. See [legal/PRIVACY_POLICY.md](legal/PRIVACY_POLICY.md).

## Platforms

| Platform | Form | Architectures |
|---|---|---|
| Windows | Fullscreen app **and** a real `.scr` screen saver | x64 (also runs on ARM64 via emulation) |
| Android | Fullscreen app; keeps the screen awake so it works as a bedside/charging clock | universal |
| macOS | Fullscreen app | universal |

**One Windows build covers every PC.** Flutter ships no Windows ARM64 SDK — every entry in its `releases_windows.json` is `dart_sdk_arch: x64` — so a native ARM64 binary cannot be produced. Windows on ARM runs the x64 build under emulation, which is how this app was developed and tested. There is no x86 (32-bit) build either: Flutter dropped that target, and 32-bit-only PCs are effectively extinct.

**Android has no system screen saver entry.** A Daydream service was written but is not shipped — a Flutter view inside Android's `DreamService` proved unreliable on device. See [CONTRIBUTING.md](CONTRIBUTING.md) for details and how to retry it.

**iOS/iPadOS is not distributed.** The source is Flutter-based and could be built for iOS, but without a paid Apple Developer account we cannot distribute an installable build outside the App Store, which is out of scope for this project. Feel free to build it yourself from `app/`.

## Repository layout

```
app/            Flutter source (single project, all platforms)
windows/x64/    Staged Windows release artifact (x64; runs on ARM64 too)
android/        Staged Android release artifact
apple/macos/    Staged macOS release artifact
legal/          License, privacy policy, trademark notice
```

## Installing

Download the latest release for your platform from the [website](https://www.tichysimon.cz/FlipTheClock/) or from [GitHub Releases](../../releases).

- **Windows**: extract `FlipTheClock-windows-x64.zip`, then right-click `Install.ps1` → **Run with PowerShell**. It copies everything to `%LOCALAPPDATA%\FlipTheClock`, adds a Start menu entry for the app and registers the screen saver — no administrator rights, and only your own account is affected. `Uninstall.ps1` reverses it. Installing is optional: `FlipTheClock.exe` runs straight from the extracted folder. Keep that folder together — a Flutter app is not a single binary, so both executables need the DLLs and `data\` beside them.
- **Android**: install the `.apk` (enable "install from unknown sources" if prompted). The app keeps the screen on while open, so it can sit on a charger as a bedside clock.
- **macOS**: unzip and drag `FlipTheClock.app` into `/Applications`. The build is not signed with an Apple Developer ID and is not notarized, so Gatekeeper blocks it on first launch. On macOS 14 and earlier, right-click the app and choose **Open**. On macOS 15 (Sequoia) and later that shortcut was removed — try to open it once, then go to **System Settings → Privacy & Security** and click **Open Anyway** next to the blocked-app message. You only need to do this once.

## App or screen saver

The Windows package contains one program under two names, and the name it
is started as decides what it does.

| File | What it is |
| --- | --- |
| `FlipTheClock.exe` | The app. Fullscreen clock with a settings button in the corner; clicking does not close it. Alt+F4 to quit. |
| `FlipTheClock.scr` | The screen saver. Windows starts it on idle, and any key or mouse movement ends it. It has no controls by design: on a screen saver the first click must dismiss it, so there is nothing it could usefully show. |

Both read the same settings, so a change made in either applies to both.

Windows' own context menu for `.scr` files is misleading here, which is
worth knowing before you go looking for the app in it:

| Menu entry | What it actually does |
| --- | --- |
| **Open** (and a plain double-click) | Runs the **screen saver** (`/S`), not the app |
| **Install** | Only opens the screen saver settings dialog |
| **Configure** | Opens FlipTheClock!'s settings (`/c`) |

Launch `FlipTheClock.exe` when you want the app. On the other platforms
the question does not arise: Android and macOS ship the app only, since
neither offers a screen saver slot this can plug into (see
[CONTRIBUTING.md](CONTRIBUTING.md) for the Android story).

## Building from source

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](legal/LICENSE)
