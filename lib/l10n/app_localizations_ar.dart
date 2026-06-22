// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'BrickClub';

  @override
  String get profileLanguage => 'اللغة';

  @override
  String get languageScreenTitle => 'اللغة';

  @override
  String get languageHeading => 'لغة العرض';

  @override
  String get languageDescription =>
      'اختر اللغة التي يستخدمها BrickClub على هذا الجهاز.';

  @override
  String get languageSystemDefault => 'إعداد النظام الافتراضي';
}
