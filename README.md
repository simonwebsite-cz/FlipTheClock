# FlipTheClock

An open-source flip-clock screensaver and app for Windows, Android, and macOS. Not affiliated with Fliqlo — see [legal/TRADEMARK_NOTICE.md](legal/TRADEMARK_NOTICE.md).

100% offline. No accounts, no analytics, no ads, no network permission. See [legal/PRIVACY_POLICY.md](legal/PRIVACY_POLICY.md).

## Platforms

| Platform | Form | Architectures |
|---|---|---|
| Windows | Real `.scr` screensaver | x64, ARM64 |
| Android | Fullscreen app; keeps the screen awake so it works as a bedside/charging clock | universal |
| macOS | Fullscreen app | universal |

**Windows x86 (32-bit) is not supported.** Flutter's Windows target only builds for x64 and ARM64, and 32-bit-only PCs are effectively extinct — there is no x86 build.

**Android has no system screen saver entry.** A Daydream service was written but is not shipped — a Flutter view inside Android's `DreamService` proved unreliable on device. See [CONTRIBUTING.md](CONTRIBUTING.md) for details and how to retry it.

**iOS/iPadOS is not distributed.** The source is Flutter-based and could be built for iOS, but without a paid Apple Developer account we cannot distribute an installable build outside the App Store, which is out of scope for this project. Feel free to build it yourself from `app/`.

## Repository layout

```
app/            Flutter source (single project, all platforms)
windows/x64/    Staged Windows x64 release artifacts
windows/arm/    Staged Windows ARM64 release artifacts
android/        Staged Android release artifact
apple/macos/    Staged macOS release artifact
legal/          License, privacy policy, trademark notice
```

## Installing

Download the latest release for your platform from [GitHub Releases](../../releases).

- **Windows**: run the installer, then set it as your screensaver in Settings → Lock screen → Screen saver settings.
- **Android**: install the `.apk` (enable "install from unknown sources" if prompted). The app keeps the screen on while open, so it can sit on a charger as a bedside clock.
- **macOS**: open the `.app`. Since it isn't notarized by an Apple Developer account, Gatekeeper will warn "unidentified developer" on first launch — right-click the app and choose **Open** to proceed past that warning once.

## Building from source

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](legal/LICENSE)
