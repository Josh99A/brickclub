/// Web implementation backed by the `brickclubPwa` shim in `web/index.html`.
library;

import 'dart:js_interop';

@JS('brickclubPwa.canInstall')
external bool _canInstall();

@JS('brickclubPwa.platform')
external JSString _platform();

@JS('brickclubPwa.isStandalone')
external bool _isStandalone();

@JS('brickclubPwa.prompt')
external JSPromise<JSString> _prompt();

/// Whether the browser captured an installable PWA prompt.
bool canInstallPwa() => _canInstall();

/// The current device family: `'ios'`, `'android'`, or `'desktop'`.
String pwaPlatform() => _platform().toDart;

/// Whether the app is already running as an installed standalone PWA.
bool isPwaStandalone() => _isStandalone();

/// Triggers the captured browser install prompt and resolves with the user's
/// choice outcome (`'accepted'`, `'dismissed'`) or `'unavailable'`.
Future<String> promptPwaInstall() async {
  final outcome = await _prompt().toDart;
  return outcome.toDart;
}
