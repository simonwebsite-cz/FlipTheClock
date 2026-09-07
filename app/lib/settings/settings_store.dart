import 'package:shared_preferences/shared_preferences.dart';

import 'settings_model.dart';

/// Reads and writes [ClockSettings] to on-device local storage
/// (SharedPreferences). Nothing here ever touches the network.
class SettingsStore {
  static const _keyUse24Hour = 'use24HourFormat';
  static const _keyShowSeconds = 'showSeconds';
  static const _keyShowDate = 'showDate';
  static const _keyPaletteIndex = 'paletteIndex';
  static const _keyFontScale = 'fontScale';
  static const _keyBoxScale = 'boxScale';
  static const _keyKeepScreenOn = 'keepScreenOn';

  Future<ClockSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ClockSettings(
      use24HourFormat: prefs.getBool(_keyUse24Hour) ?? true,
      showSeconds: prefs.getBool(_keyShowSeconds) ?? false,
      showDate: prefs.getBool(_keyShowDate) ?? true,
      paletteIndex: prefs.getInt(_keyPaletteIndex) ?? 0,
      fontScale: prefs.getDouble(_keyFontScale) ?? 1.0,
      boxScale: prefs.getDouble(_keyBoxScale) ?? 1.0,
      keepScreenOn: prefs.getBool(_keyKeepScreenOn) ?? true,
    );
  }

  Future<void> save(ClockSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUse24Hour, settings.use24HourFormat);
    await prefs.setBool(_keyShowSeconds, settings.showSeconds);
    await prefs.setBool(_keyShowDate, settings.showDate);
    await prefs.setInt(_keyPaletteIndex, settings.paletteIndex);
    await prefs.setDouble(_keyFontScale, settings.fontScale);
    await prefs.setDouble(_keyBoxScale, settings.boxScale);
    await prefs.setBool(_keyKeepScreenOn, settings.keepScreenOn);
  }
}
