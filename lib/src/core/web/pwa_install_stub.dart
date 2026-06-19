/// Non-web stub: native builds cannot install a PWA.
library;

/// Whether the browser has offered an installable PWA prompt.
bool canInstallPwa() => false;

/// The current device family. Always `'desktop'` off the web.
String pwaPlatform() => 'desktop';

/// Whether the app is already running as an installed standalone PWA.
bool isPwaStandalone() => false;

/// Triggers the browser install prompt. Returns the user's choice outcome
/// (`'accepted'`, `'dismissed'`) or `'unavailable'` when no prompt exists.
Future<String> promptPwaInstall() async => 'unavailable';
