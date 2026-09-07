/// What the process was asked to do, per the standard Windows screensaver
/// command-line convention: `/s` (show), `/c` or `/c:<hwnd>` (configure),
/// `/p <hwnd>` (render a live preview inside that window). Any other
/// invocation (e.g. a plain double-click, or running on a platform that
/// has no such convention) is [ScreensaverMode.standalone].
enum ScreensaverMode { show, configure, preview, standalone }

class ParsedScreensaverArgs {
  const ParsedScreensaverArgs(this.mode, {this.parentWindowHandle});

  final ScreensaverMode mode;

  /// The HWND (as a decimal or hex string from argv) to configure a
  /// dialog as a child of, or to embed the live preview into.
  final String? parentWindowHandle;
}

ParsedScreensaverArgs parseScreensaverArgs(List<String> args) {
  if (args.isEmpty) {
    return const ParsedScreensaverArgs(ScreensaverMode.standalone);
  }

  final first = args.first.toLowerCase();

  if (first.startsWith('/s') || first.startsWith('-s')) {
    return const ParsedScreensaverArgs(ScreensaverMode.show);
  }

  if (first.startsWith('/c') || first.startsWith('-c')) {
    // Accepts both "/c:12345" (one token) and "/c 12345" (two tokens).
    final colonIndex = first.indexOf(':');
    String? hwnd;
    if (colonIndex != -1 && colonIndex + 1 < first.length) {
      hwnd = first.substring(colonIndex + 1);
    } else if (args.length > 1) {
      hwnd = args[1];
    }
    return ParsedScreensaverArgs(ScreensaverMode.configure, parentWindowHandle: hwnd);
  }

  if (first.startsWith('/p') || first.startsWith('-p')) {
    final colonIndex = first.indexOf(':');
    String? hwnd;
    if (colonIndex != -1 && colonIndex + 1 < first.length) {
      hwnd = first.substring(colonIndex + 1);
    } else if (args.length > 1) {
      hwnd = args[1];
    }
    return ParsedScreensaverArgs(ScreensaverMode.preview, parentWindowHandle: hwnd);
  }

  return const ParsedScreensaverArgs(ScreensaverMode.standalone);
}
