// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'BrickClub';

  @override
  String get profileLanguage => 'Idioma';

  @override
  String get languageScreenTitle => 'Idioma';

  @override
  String get languageHeading => 'Idioma de visualización';

  @override
  String get languageDescription =>
      'Elige el idioma que BrickClub usa en este dispositivo.';

  @override
  String get languageSystemDefault => 'Predeterminado del sistema';
}
