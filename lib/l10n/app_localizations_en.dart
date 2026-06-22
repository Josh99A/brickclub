// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BrickClub';

  @override
  String get profileLanguage => 'Language';

  @override
  String get languageScreenTitle => 'Language';

  @override
  String get languageHeading => 'Display language';

  @override
  String get languageDescription =>
      'Choose the language BrickClub uses on this device.';

  @override
  String get languageSystemDefault => 'System default';
}
