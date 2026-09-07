import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:window_manager/window_manager.dart';

import 'clock/flip_clock.dart';
import 'platform/screensaver_args.dart';
import 'settings/settings_model.dart';
import 'settings/settings_screen.dart';
import 'settings/settings_store.dart';

// Desktop window chrome only exists on Windows/macOS/Linux; Android has no
// concept of it and window_manager doesn't support Android at all.
bool get _isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

/// Mobile only: hold a wake lock so the display stays on while the clock
/// is showing. Desktop keeps its screen awake by other means (the Windows
/// screensaver path is itself what runs when the machine idles), and
/// wakelock_plus is a no-op there anyway.
Future<void> _applyKeepScreenOn(bool enabled) async {
  if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;
  try {
    await WakelockPlus.toggle(enable: enabled);
  } catch (_) {
    // A missing wake lock must never take the clock down with it.
  }
}

/// Sizes and positions the window to exactly cover the primary display and
/// hides its title bar.
///
/// This deliberately does NOT use `windowManager.setFullScreen(true)`: on
/// Windows that toggles the OS-level fullscreen state without reliably
/// triggering a Flutter relayout, leaving `MediaQuery` reporting a stale
/// size and the clock rendering off-center against the real (now larger)
/// window. Explicitly setting bounds to the real display size goes through
/// the normal resize path instead, which the engine does handle correctly.
Future<void> _makeFullscreenBorderless() async {
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  final display = await screenRetriever.getPrimaryDisplay();
  await windowManager.setBounds(
    Rect.fromLTWH(0, 0, display.size.width, display.size.height),
  );
  // Without this the taskbar (itself always-on-top) shows through/over the
  // bottom of the window even though the window is sized to the full
  // display — the window needs to be above it in z-order, not just sized
  // to cover it.
  await windowManager.setAlwaysOnTop(true);
}

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final parsedArgs = Platform.isWindows
      ? parseScreensaverArgs(args)
      : const ParsedScreensaverArgs(ScreensaverMode.standalone);

  if (_isDesktop) {
    await windowManager.ensureInitialized();
  }

  final settings = await SettingsStore().load();

  runApp(FlipTheClockApp(mode: parsedArgs.mode, initialSettings: settings));
}

class FlipTheClockApp extends StatelessWidget {
  const FlipTheClockApp({super.key, required this.mode, required this.initialSettings});

  final ScreensaverMode mode;
  final ClockSettings initialSettings;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlipTheClock!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Anton',
        scaffoldBackgroundColor: kClockBackground,
        appBarTheme: const AppBarTheme(backgroundColor: kClockBackground, surfaceTintColor: Colors.transparent),
      ),
      home: switch (mode) {
        ScreensaverMode.configure => _ConfigureRoot(initialSettings: initialSettings),
        ScreensaverMode.show => _FullscreenRoot(initialSettings: initialSettings, exitOnInput: true),
        ScreensaverMode.preview => _FullscreenRoot(initialSettings: initialSettings, exitOnInput: false),
        ScreensaverMode.standalone => _StandaloneRoot(initialSettings: initialSettings),
      },
    );
  }
}

/// `/c` — a normal, resizable settings window.
class _ConfigureRoot extends StatefulWidget {
  const _ConfigureRoot({required this.initialSettings});

  final ClockSettings initialSettings;

  @override
  State<_ConfigureRoot> createState() => _ConfigureRootState();
}

class _ConfigureRootState extends State<_ConfigureRoot> {
  final _store = SettingsStore();

  @override
  void initState() {
    super.initState();
    if (_isDesktop) {
      windowManager.setFullScreen(false);
      windowManager.setTitleBarStyle(TitleBarStyle.normal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(
      initial: widget.initialSettings,
      onSave: (s) => _store.save(s),
    );
  }
}

/// `/s` (real screensaver, exits on any input) and `/p` (preview pane
/// render, non-interactive) — a borderless fullscreen clock with no chrome.
class _FullscreenRoot extends StatefulWidget {
  const _FullscreenRoot({required this.initialSettings, required this.exitOnInput});

  final ClockSettings initialSettings;
  final bool exitOnInput;

  @override
  State<_FullscreenRoot> createState() => _FullscreenRootState();
}

class _FullscreenRootState extends State<_FullscreenRoot> with WindowListener {
  Offset? _lastPointer;
  static const _moveExitThreshold = 12.0;

  @override
  void initState() {
    super.initState();
    // Deferred to after the first frame: calling this synchronously in
    // initState races the native window's own creation on Windows.
    if (_isDesktop) {
      windowManager.addListener(this);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _makeFullscreenBorderless();
      });
    }
  }

  @override
  void dispose() {
    if (_isDesktop) windowManager.removeListener(this);
    super.dispose();
  }

  // Alt-Tab away and this should behave like a normal window that yields
  // to whatever the user switches to — only sit above the taskbar while
  // actually focused, not permanently on top of every other window.
  @override
  void onWindowFocus() => windowManager.setAlwaysOnTop(true);

  @override
  void onWindowBlur() => windowManager.setAlwaysOnTop(false);

  void _exit() {
    if (widget.exitOnInput) exit(0);
  }

  void _onPointerMove(PointerEvent event) {
    if (!widget.exitOnInput) return;
    final last = _lastPointer;
    _lastPointer = event.position;
    if (last != null && (event.position - last).distance > _moveExitThreshold) {
      _exit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _exit(),
      onPointerMove: _onPointerMove,
      onPointerSignal: (_) => _exit(),
      child: KeyboardListener(
        autofocus: widget.exitOnInput,
        focusNode: FocusNode(),
        onKeyEvent: (_) => _exit(),
        child: FlipClock(settings: widget.initialSettings),
      ),
    );
  }
}

/// No screensaver args at all — a plain double-click launch on desktop, or
/// the only launch path on Android. Fullscreen clock with a small, always-
/// reachable settings entry point (there's no OS-driven /c invocation here).
class _StandaloneRoot extends StatefulWidget {
  const _StandaloneRoot({required this.initialSettings});

  final ClockSettings initialSettings;

  @override
  State<_StandaloneRoot> createState() => _StandaloneRootState();
}

class _StandaloneRootState extends State<_StandaloneRoot> with WindowListener {
  late ClockSettings _settings;
  final _store = SettingsStore();

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
    _applyKeepScreenOn(_settings.keepScreenOn);
    // A standalone launch (double-click, or macOS/Linux which have no /s
    // /c /p convention of their own) still presents as a fullscreen clock —
    // the settings gear in the corner is the only way back, matching how
    // the real screensaver (/s) behaves. Deferred to after the first frame
    // for the same reason as _FullscreenRoot.
    if (_isDesktop) {
      windowManager.addListener(this);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _makeFullscreenBorderless();
      });
    }
  }

  @override
  void dispose() {
    if (_isDesktop) windowManager.removeListener(this);
    super.dispose();
  }

  // Same as _FullscreenRoot: stay above the taskbar only while focused, so
  // Alt-Tab correctly switches to whatever else the user picks.
  @override
  void onWindowFocus() => windowManager.setAlwaysOnTop(true);

  @override
  void onWindowBlur() => windowManager.setAlwaysOnTop(false);

  void _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          initial: _settings,
          onSave: (s) {
            setState(() => _settings = s);
            _store.save(s);
            _applyKeepScreenOn(s.keepScreenOn);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: FlipClock(settings: _settings)),
        Positioned(
          top: 16,
          right: 16,
          child: SafeArea(
            child: IconButton(
              icon: Icon(Icons.settings, color: _settings.palette.foreground.withValues(alpha: 0.5)),
              onPressed: _openSettings,
            ),
          ),
        ),
      ],
    );
  }
}
