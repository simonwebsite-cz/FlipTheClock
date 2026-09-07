import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flip_the_clock/clock/flip_clock.dart';
import 'package:flip_the_clock/main.dart';
import 'package:flip_the_clock/platform/screensaver_args.dart';
import 'package:flip_the_clock/settings/settings_model.dart';

void main() {
  testWidgets('standalone mode renders the flip clock', (tester) async {
    await tester.pumpWidget(
      const FlipTheClockApp(
        mode: ScreensaverMode.standalone,
        initialSettings: ClockSettings(),
      ),
    );
    await tester.pump();

    expect(find.byType(FlipClock), findsOneWidget);
  });

  testWidgets('portrait (phone-sized) window stacks pairs without overflowing', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const FlipTheClockApp(
        mode: ScreensaverMode.standalone,
        initialSettings: ClockSettings(showSeconds: true),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(FlipClock), findsOneWidget);
  });

  test('screensaver arg parsing follows the /s /c /p convention', () {
    expect(parseScreensaverArgs([]).mode, ScreensaverMode.standalone);
    expect(parseScreensaverArgs(['/s']).mode, ScreensaverMode.show);

    final configure = parseScreensaverArgs(['/c:12345']);
    expect(configure.mode, ScreensaverMode.configure);
    expect(configure.parentWindowHandle, '12345');

    final preview = parseScreensaverArgs(['/p', '67890']);
    expect(preview.mode, ScreensaverMode.preview);
    expect(preview.parentWindowHandle, '67890');
  });
}
