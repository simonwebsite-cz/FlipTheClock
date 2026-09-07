import 'package:flutter/material.dart';

import 'settings_model.dart';

/// The `/c` configuration screen: a standalone settings page (no clock
/// preview mixed in) that reports each change back via [onSave].
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.initial, required this.onSave});

  final ClockSettings initial;
  final ValueChanged<ClockSettings> onSave;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ClockSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initial;
  }

  void _update(ClockSettings Function(ClockSettings) change) {
    setState(() => _settings = change(_settings));
    widget.onSave(_settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset('assets/img/logo_FlipTheClock.jpg', width: 28, height: 28, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),
            const Text('FlipTheClock!'),
          ],
        ),
      ),
      body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  title: const Text('24-hour format'),
                  value: _settings.use24HourFormat,
                  onChanged: (v) => _update((s) => s.copyWith(use24HourFormat: v)),
                ),
                SwitchListTile(
                  title: const Text('Show seconds'),
                  value: _settings.showSeconds,
                  onChanged: (v) => _update((s) => s.copyWith(showSeconds: v)),
                ),
                SwitchListTile(
                  title: const Text('Keep screen on'),
                  subtitle: const Text('Stops the display sleeping while the clock is open'),
                  value: _settings.keepScreenOn,
                  onChanged: (v) => _update((s) => s.copyWith(keepScreenOn: v)),
                ),
                SwitchListTile(
                  title: const Text('Show date'),
                  value: _settings.showDate,
                  onChanged: (v) => _update((s) => s.copyWith(showDate: v)),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 12, bottom: 8),
                  child: Text('Color theme', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Wrap(
                  spacing: 12,
                  children: [
                    for (var i = 0; i < kPalettes.length; i++)
                      _PaletteSwatch(
                        palette: kPalettes[i],
                        selected: _settings.paletteIndex == i,
                        onTap: () => _update((s) => s.copyWith(paletteIndex: i)),
                      ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 4),
                  child: Text('Digit size', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Text(
                  'How big the whole clock is on screen (${(_settings.boxScale * 100).round()}%)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Slider(
                  value: _settings.boxScale,
                  min: 0.4,
                  max: 1.0,
                  divisions: 12,
                  label: '${(_settings.boxScale * 100).round()}%',
                  onChanged: (v) => _update((s) => s.copyWith(boxScale: v)),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 12, bottom: 4),
                  child: Text('Font weight', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Text(
                  'How much of each card the digit fills (${(_settings.fontScale * 100).round()}%)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Slider(
                  value: _settings.fontScale,
                  min: 0.6,
                  max: 1.3,
                  divisions: 14,
                  label: '${(_settings.fontScale * 100).round()}%',
                  onChanged: (v) => _update((s) => s.copyWith(fontScale: v)),
                ),
              ],
      ),
    );
  }
}

class _PaletteSwatch extends StatelessWidget {
  const _PaletteSwatch({required this.palette, required this.selected, required this.onTap});

  final ClockPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 88,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: kClockBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : Colors.white24,
            width: 3,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          palette.name,
          style: TextStyle(color: palette.foreground, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
