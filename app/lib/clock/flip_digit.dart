import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A single flip-card character (digit or symbol) that animates between
/// its old and new value with a hinge-flip, the way a mechanical
/// split-flap display works: the old top half falls away, then the new
/// bottom half rises into place.
class FlipDigit extends StatefulWidget {
  const FlipDigit({
    super.key,
    required this.value,
    required this.width,
    required this.height,
    required this.textStyle,
    required this.cardColor,
    this.duration = const Duration(milliseconds: 500),
    this.cornerRadius = 0,
  });

  final String value;
  final double width;
  final double height;
  final TextStyle textStyle;
  final Color cardColor;
  final Duration duration;

  /// Corner rounding for this digit's own edges. Defaults to 0 because
  /// digits are normally grouped in pairs (hour/minute) behind one shared
  /// rounded [ClipRRect] at the call site — see [FlipClock] — matching the
  /// reference design where a pair reads as a single rounded module with a
  /// plain seam between its two digits, not two independently rounded cards.
  final double cornerRadius;

  @override
  State<FlipDigit> createState() => _FlipDigitState();
}

class _FlipDigitState extends State<FlipDigit> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late String _oldValue;
  late String _newValue;

  @override
  void initState() {
    super.initState();
    _oldValue = widget.value;
    _newValue = widget.value;
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didUpdateWidget(covariant FlipDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _newValue = widget.value;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Resting halves: the top half already shows the incoming
              // value (it's hidden behind flap 1 until that flap rotates
              // out of the way). The bottom half shows the outgoing value
              // until the halfway point, then snaps to the new value right
              // as flap 2 arrives to cover it.
              Positioned(top: 0, left: 0, right: 0, child: _halfCard(_newValue, top: true)),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _halfCard(t < 0.5 ? _oldValue : _newValue, top: false),
              ),
              if (t <= 0.5)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _flap(value: _oldValue, top: true, angle: _lerp(0, math.pi / 2, t / 0.5)),
                ),
              if (t > 0.5)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _flap(
                    value: _newValue,
                    top: false,
                    angle: _lerp(-math.pi / 2, 0, (t - 0.5) / 0.5),
                  ),
                ),
              IgnorePointer(child: Align(alignment: Alignment.center, child: _hingeShadow())),
            ],
          );
        },
      ),
    );
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t.clamp(0.0, 1.0);

  /// A card slice half [widget.height] tall showing the top or bottom half
  /// of [value]'s glyph. The glyph is laid out in a full-card-height
  /// container positioned to show only its top or bottom half through the
  /// half-height viewport, so a single continuous top-lit gradient (defined
  /// across that full height) reads as one physical card cut by the hinge,
  /// rather than two independently-lit pieces.
  Widget _halfCard(String value, {required bool top, double foldShade = 0}) {
    final radius = Radius.circular(widget.cornerRadius);
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: top ? radius : Radius.zero,
        bottom: top ? Radius.zero : radius,
      ),
      child: SizedBox(
        width: widget.width,
        height: widget.height / 2,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              top: top ? 0 : -(widget.height / 2),
              left: 0,
              right: 0,
              height: widget.height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.lerp(widget.cardColor, Colors.white, 0.05)!,
                      Color.lerp(widget.cardColor, Colors.black, 0.35)!,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    RepaintBoundary(
                      // Anton's line box reserves noticeably more space
                      // above the glyph than below it, so a plain Center
                      // reads as "pinned near the top" — nudge down to
                      // land on the card's true visual center instead.
                      child: Transform.translate(
                        offset: Offset(0, widget.height * 0.07),
                        child: Center(child: Text(value, style: widget.textStyle)),
                      ),
                    ),
                    if (foldShade > 0)
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: foldShade)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _flap({required String value, required bool top, required double angle}) {
    // Cards catch less light the further they've folded toward edge-on;
    // this scrim peaks at 90° (the same instant the flap is a sliver and
    // about to disappear/arrive) for a subtle, physically-motivated fold.
    final foldShade = math.sin(angle.abs()).clamp(0.0, 1.0) * 0.45;
    return Transform(
      alignment: top ? Alignment.bottomCenter : Alignment.topCenter,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0015)
        ..rotateX(angle),
      child: _halfCard(value, top: top, foldShade: foldShade),
    );
  }

  Widget _hingeShadow() {
    return Container(
      width: widget.width,
      height: (widget.height * 0.008).clamp(1.5, 3.0),
      color: Colors.black,
    );
  }
}
