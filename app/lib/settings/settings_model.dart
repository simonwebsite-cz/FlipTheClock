import 'package:flutter/material.dart';

/// Every palette shares the same pure-black background — only the digit
/// color varies. A light "Paper" option existed earlier but was dropped:
/// this app is a screensaver meant for a dark room, not a print layout.
const Color kClockBackground = Colors.black;

/// A named digit color.
class ClockPalette {
  const ClockPalette(this.name, this.foreground);

  final String name;
  final Color foreground;
}

const List<ClockPalette> kPalettes = [
  ClockPalette('Classic', Colors.white),
  ClockPalette('Amber', Color(0xFFFFB300)),
  ClockPalette('Ice', Color(0xFF7FDBFF)),
];

@immutable
class ClockSettings {
  const ClockSettings({
    this.use24HourFormat = true,
    this.showSeconds = false,
    this.showDate = true,
    this.paletteIndex = 0,
    this.fontScale = 1.0,
    this.boxScale = 1.0,
    this.keepScreenOn = true,
  });

  final bool use24HourFormat;
  final bool showSeconds;
  final bool showDate;
  final int paletteIndex;

  /// Scales the digit glyph size relative to its card, independent of the
  /// card's own size (see [boxScale]). 1.0 is the default fit.
  final double fontScale;

  /// Scales the overall card/digit size relative to the auto-fit-to-screen
  /// default. 1.0 fills the screen (minus the edge margin); lower values
  /// shrink the whole clock, leaving more black space around it.
  final double boxScale;

  /// Holds a wake lock while the clock is on screen, so a phone left
  /// on a charger keeps showing the time instead of sleeping.
  /// Ignored on desktop, which has no wake lock concept here.
  final bool keepScreenOn;

  ClockPalette get palette => kPalettes[paletteIndex.clamp(0, kPalettes.length - 1)];

  ClockSettings copyWith({
    bool? use24HourFormat,
    bool? showSeconds,
    bool? showDate,
    int? paletteIndex,
    double? fontScale,
    double? boxScale,
    bool? keepScreenOn,
  }) {
    return ClockSettings(
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      showSeconds: showSeconds ?? this.showSeconds,
      showDate: showDate ?? this.showDate,
      paletteIndex: paletteIndex ?? this.paletteIndex,
      fontScale: fontScale ?? this.fontScale,
      boxScale: boxScale ?? this.boxScale,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    );
  }
}
