# Contributing to FlipTheClock

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel), with `windows`, `android`, and `macos` platform support enabled (`flutter config --enable-windows-desktop --enable-macos-desktop`).
- Platform toolchains as required by Flutter: Visual Studio (Desktop C++ workload) for Windows, Android Studio/SDK for Android, Xcode for macOS.

## Project layout

All application source lives in `app/`, a single Flutter project targeting Windows, Android, and macOS. Platform-specific native code (Windows screensaver argument handling, the Android Daydream service) lives inside `app/windows/runner/` and `app/android/`, which are the standard Flutter-provided customization points for each platform — not separate codebases.

```
app/lib/main.dart      Entry point; parses Windows /s /c /p screensaver arguments
app/lib/clock/         Flip-clock rendering
app/lib/settings/      User preferences (12h/24h, seconds, date, theme, font)
app/lib/platform/      Platform-channel bridges (Win32 HWND handling, Daydream bridge)
```

## Running locally

```bash
cd app
flutter pub get
flutter run -d windows   # or: -d macos / -d <android-device-id>
```

## Building a release

`flutter build windows` always targets the machine's own architecture —
there is no flag to cross-compile x64 vs ARM64. Run it from a real x64
Windows machine for the x64 build, and from a real ARM64 Windows machine
for the ARM64 build.

```bash
cd app
flutter build windows --release   # produces x64 or arm64 depending on the host
flutter build apk --release
flutter build macos --release
```

Release artifacts are staged into the top-level `windows/x64/`, `windows/arm/`, `android/`, and `apple/macos/` folders by the CI workflow (`.github/workflows/release.yml`) on tag push, which runs the Windows builds on separate x64 and ARM64 runners — you don't need to do this by hand for a PR.

### Android release signing

Without a release keystore the APK falls back to Flutter's **debug** key,
so it still builds, but must not be published: the debug key is public,
meaning anyone could sign a malicious "update" that Android accepts as
the same app, and update continuity breaks.

To produce a distributable APK, generate your own keystore once:

```bash
keytool -genkey -v -keystore fliptheclock-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias fliptheclock
```

Keep the `.jks` somewhere outside the repo, then create
`app/android/key.properties` (gitignored, never commit it):

```properties
storePassword=<the store password you chose>
keyPassword=<the key password you chose>
keyAlias=fliptheclock
storeFile=C:/path/to/fliptheclock-release.jks
```

`flutter build apk --release` then signs with that key automatically.
Back the keystore up — losing it means you can never ship an update to
an already-installed copy of the app.

#### Signing in CI

`key.properties` and the `.jks` are gitignored, so the release workflow
rebuilds them from repository secrets (Settings -> Secrets and variables
-> Actions):

| Secret | Value |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | the `.jks` file, base64-encoded |
| `ANDROID_STORE_PASSWORD` | store password chosen at `keytool` time |
| `ANDROID_KEY_PASSWORD` | key password chosen at `keytool` time |
| `ANDROID_KEY_ALIAS` | `fliptheclock` |

Encode the keystore with PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\path	oliptheclock-release.jks")) | Set-Clipboard
```

or on macOS/Linux:

```bash
base64 -w0 fliptheclock-release.jks
```

If `ANDROID_KEYSTORE_BASE64` is missing the workflow fails on purpose
rather than publishing a debug-signed APK, and a further `apksigner`
check after the build rejects the artifact if the debug certificate
ended up on it anyway.

### Android sideloading warnings

Even correctly signed, an APK installed outside the Play Store triggers
Play Protect "unknown source" warnings — that's inherent to sideloading,
not a signing problem. Proper signing removes the debug-key class of
warnings and makes updates work; it does not make Play Protect silent.

### Known issue: Android Daydream screen saver is not shipped

`FlipTheClockDreamService.kt` hosts a `FlutterView` inside a
`DreamService` so the clock could be picked in Settings -> Display ->
Screen saver. It is written and compiles, but it is **not registered in
`AndroidManifest.xml`** and therefore does not appear on the device.

On a real device (Android 15) it rendered a static frame, a black screen,
or worked on roughly every other launch, inconsistently. Fixes attempted:

- driving `lifecycleChannel.appIsResumed()` from `onDreamingStarted()`
  (an Activity normally does this; without it the engine never schedules
  a frame)
- also resuming right after `attachToFlutterEngine()`, to cover the
  settings "Preview" path which does not reliably deliver that callback
- reusing one cached engine via `FlutterEngineCache` instead of creating
  and destroying a `FlutterEngine` per dream

None made it dependable. A `FlutterView` in a `DreamService` is not an
officially supported Flutter embedding, so rather than ship a screen
saver entry that mostly does not work, the app keeps the screen awake
while open (`MainActivity`) and serves as a bedside/charging clock.

To retry: re-add the `<service>` block described in the manifest comment.

### Android builds inside OneDrive (or any cloud-synced folder)

If the checkout lives in a synced folder, the sync client locks build
artifacts or converts them to cloud placeholders mid-build. Gradle then
fails with things like:

- `Unable to delete directory ... Failed to delete some children`
- `Failed to create MD5 hash for file: ...` /
  `Accessing unreadable inputs or outputs is not supported`

These are not code problems and retrying alone doesn't fix them. Pause
syncing for the duration of the build (OneDrive tray icon → Pause
syncing), then clean the poisoned state before rebuilding:

```powershell
Get-Process java | Stop-Process -Force      # stale Gradle daemons hold files
Remove-Item -Recurse -Force app\build, app\android\.gradle
```

### Android path with non-ASCII characters

The Android Gradle Plugin refuses to build from a path containing
non-ASCII characters, and Flutter's own Gradle integration double-URL-
encodes such paths and then fails to read them back. `gradle.properties`
sets `android.overridePathCheck=true` for the first problem; the second
has no override — build from an ASCII-only path (e.g. a directory
junction: `mklink /J C:\dev\FlipTheClock "<real path>"`).

## Known issue: text rendering artifact on Qualcomm Adreno GPUs (Windows ARM64)

On at least one Snapdragon X Elite/Plus device (Adreno X1-45 GPU), the
large clock digits render with a thin yellow horizontal artifact beneath
each glyph. This reproduces identically regardless of the widget tree
used to lay out the digit (tried: `OverflowBox`, `Stack`+`Positioned`,
with/without `RepaintBoundary`, at multiple font sizes) and does not
appear in `flutter analyze`/`flutter test` as any kind of layout
overflow — it's a rendering-backend issue, not an app bug. It's
consistent with Flutter's Impeller renderer having known text-rendering
artifacts on certain GPU/driver combinations (see e.g.
[flutter/flutter#160948](https://github.com/flutter/flutter/issues/160948)).
If you hit this, please report which GPU/driver you're on in a new issue
so we can track which hardware is affected.

## Testing

```bash
cd app
flutter analyze
flutter test
```

## Pull requests

- Keep PRs scoped to one change.
- No new dependencies that require network access, analytics, or telemetry — this project is offline by design (see [legal/PRIVACY_POLICY.md](legal/PRIVACY_POLICY.md)). A PR that would break that guarantee needs to update the privacy policy in the same PR and will get extra scrutiny.
- Don't introduce Fliqlo-derived assets (fonts, artwork, exact color values copied from screenshots) — see [legal/TRADEMARK_NOTICE.md](legal/TRADEMARK_NOTICE.md).
