// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'BrickClub';

  @override
  String get profileLanguage => 'Язык';

  @override
  String get languageScreenTitle => 'Язык';

  @override
  String get languageHeading => 'Язык интерфейса';

  @override
  String get languageDescription =>
      'Выберите язык, который BrickClub использует на этом устройстве.';

  @override
  String get languageSystemDefault => 'Системный язык';
}
