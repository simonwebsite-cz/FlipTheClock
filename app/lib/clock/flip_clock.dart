import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../settings/settings_model.dart';
import 'flip_digit.dart';

/// Renders the current time as a row of [FlipDigit] cards, ticking every
/// second off a local [Timer] — no network, no external clock source.
///
/// Proportions below (card aspect ratio, gaps, corner radius, glyph size,
/// AM/PM label size/position) are measured pixel-for-pixel from the
/// reference design in `img/FlipTheClock! Design.png`, not eyeballed.
class FlipClock extends StatefulWidget {
  const FlipClock({super.key, required this.settings});

  final ClockSettings settings;

  @override
  State<FlipClock> createState() => _FlipClockState();
}

class _FlipClockState extends State<FlipClock> {
  late DateTime _now;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _scheduleNextTick();
  }

  void _scheduleNextTick() {
    final delay = Duration(milliseconds: 1000 - _now.millisecond);
    _ticker = Timer(delay, () {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
      _scheduleNextTick();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // Gap ratios measured from the reference design (img/FlipTheClock!
  // Design.png): ~18px between digits in a pair vs ~52px between the hour
  // and minute pairs, expressed as ratios of digitHeight. Card shape itself
  // (square, rounded) is a later, deliberate departure from that reference.
  static const _digitWidthRatio = 0.55;
  static const _cardCornerRadiusRatio = 0.1;
  static const _intraPairGapRatio = 0.016;
  static const _interPairGapRatio = 0.046;

  @override
  Widget build(BuildContext context) {
    final palette = widget.settings.palette;
    final size = MediaQuery.sizeOf(context);

    final numPairs = 2 + (widget.settings.showSeconds ? 1 : 0);
    final numDigits = numPairs * 2;
    // Portrait screens (phones) are tall and narrow — a row of 2-3 wide
    // pairs doesn't fit, so pairs stack one above another instead of
    // sitting side by side. Landscape/desktop keeps the single row.
    final isPortrait = size.height > size.width;

    // Solve for the largest digitHeight that still fits the screen (minus a
    // small edge margin) in both dimensions — the clock should fill the
    // screen with only a thin margin, not sit at some fixed modest size.
    final margin = (size.shortestSide * 0.008).clamp(4.0, 16.0);
    final availableWidth = size.width - margin * 2;
    final availableHeight = size.height - margin * 2;

    final onePairWidthUnits = 2 * _digitWidthRatio + _intraPairGapRatio;
    final widthUnitsPerDigitHeight = isPortrait
        ? onePairWidthUnits
        : numDigits * _digitWidthRatio +
            (numDigits - numPairs) * _intraPairGapRatio +
            (numPairs - 1) * _interPairGapRatio;
    // The date row's real rendered height depends on the font's own line
    // height, which isn't precisely known ahead of layout — pad the
    // estimate so a small underestimate can't overflow the Column.
    final dateHeightUnits = widget.settings.showDate ? 0.32 : 0.0;
    final heightUnitsPerDigitHeight = isPortrait
        ? numPairs + (numPairs - 1) * _interPairGapRatio + dateHeightUnits
        : 1.0 + dateHeightUnits;

    final fitDigitHeight = math.min(
      availableWidth / widthUnitsPerDigitHeight,
      availableHeight / heightUnitsPerDigitHeight * 0.97,
    ).clamp(40.0, 900.0);
    // boxScale lets the user shrink the whole clock below the auto-fit
    // size (which otherwise always fills the screen edge-to-edge).
    final digitHeight = fitDigitHeight * widget.settings.boxScale;

    final digitWidth = digitHeight * _digitWidthRatio;
    final intraPairGap = digitHeight * _intraPairGapRatio;
    final interPairGap = digitHeight * _interPairGapRatio;

    final hour24 = _now.hour;
    final isAM = hour24 < 12;
    final hour = widget.settings.use24HourFormat
        ? hour24
        : (hour24 % 12 == 0 ? 12 : hour24 % 12);

    final segments = <String>[
      hour.toString().padLeft(2, '0'),
      _now.minute.toString().padLeft(2, '0'),
      if (widget.settings.showSeconds) _now.second.toString().padLeft(2, '0'),
    ];

    // Anton is a single (already very bold, condensed) weight — asking for
    // a heavier FontWeight than what's registered would make Flutter
    // synthesize a fake-bold pass, so text styles below stick to .normal.
    const fontFamily = 'Anton';
    final textStyle = TextStyle(
      fontSize: digitHeight * 0.62 * widget.settings.fontScale,
      fontWeight: FontWeight.normal,
      fontFamily: fontFamily,
      color: palette.foreground,
      height: 1,
      decoration: TextDecoration.none,
    );

    final pairWidgets = [
      for (var s = 0; s < segments.length; s++)
        _digitPair(
          segments[s],
          digitWidth,
          digitHeight,
          intraPairGap,
          textStyle,
          palette,
          label: (s == 0 && !widget.settings.use24HourFormat) ? (isAM ? 'AM' : 'PM') : null,
        ),
    ];

    return Container(
      color: kClockBackground,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isPortrait)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < pairWidgets.length; i++) ...[
                  if (i > 0) SizedBox(height: interPairGap),
                  pairWidgets[i],
                ],
              ],
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < pairWidgets.length; i++) ...[
                  if (i > 0) SizedBox(width: interPairGap),
                  pairWidgets[i],
                ],
              ],
            ),
          if (widget.settings.showDate)
            Padding(
              padding: EdgeInsets.only(top: digitHeight * 0.1),
              child: SizedBox(
                width: digitHeight * widthUnitsPerDigitHeight,
                child: Center(
                  child: Text(
                    _formatDate(_now).toUpperCase(),
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: digitHeight * 0.03,
                      color: palette.foreground.withValues(alpha: 0.7),
                      letterSpacing: 2,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Two digits as separate rounded cards with a small gap between them —
  /// matching the reference, where every digit is its own card (small gap
  /// within a pair, ~3x wider gap between the hour and minute pairs), not
  /// one seamless block. When [label] is given (AM/PM), it's overlaid
  /// inside the first card's top-left, on top of the card itself — not as
  /// a separate row above it — again matching the reference exactly.
  Widget _digitPair(
    String twoChars,
    double digitWidth,
    double digitHeight,
    double intraPairGap,
    TextStyle textStyle,
    ClockPalette palette, {
    String? label,
  }) {
    final cardColor = Color.alphaBlend(
      palette.foreground.withValues(alpha: 0.03),
      kClockBackground,
    );
    final chars = twoChars.split('');
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < chars.length; i++) ...[
              if (i > 0) SizedBox(width: intraPairGap),
              FlipDigit(
                value: chars[i],
                width: digitWidth,
                height: digitHeight,
                textStyle: textStyle,
                cardColor: cardColor,
                cornerRadius: digitHeight * _cardCornerRadiusRatio,
              ),
            ],
          ],
        ),
        if (label != null)
          Positioned(
            left: digitHeight * 0.056,
            top: digitHeight * 0.043,
            child: RepaintBoundary(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Anton',
                  fontSize: digitHeight * 0.045,
                  color: palette.foreground,
                  letterSpacing: 2,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
      ],
    );
  }

  static const _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  String _formatDate(DateTime dt) {
    final weekday = _weekdays[dt.weekday - 1];
    final month = _months[dt.month - 1];
    return '$weekday · $month ${dt.day}';
  }
}
