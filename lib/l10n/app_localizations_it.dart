// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'BrickClub';

  @override
  String get profileLanguage => 'Lingua';

  @override
  String get languageScreenTitle => 'Lingua';

  @override
  String get languageHeading => 'Lingua di visualizzazione';

  @override
  String get languageDescription =>
      'Scegli la lingua che BrickClub usa su questo dispositivo.';

  @override
  String get languageSystemDefault => 'Predefinito di sistema';
}
