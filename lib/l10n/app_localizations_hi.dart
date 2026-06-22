// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'BrickClub';

  @override
  String get profileLanguage => 'भाषा';

  @override
  String get languageScreenTitle => 'भाषा';

  @override
  String get languageHeading => 'प्रदर्शन भाषा';

  @override
  String get languageDescription =>
      'इस डिवाइस पर BrickClub द्वारा उपयोग की जाने वाली भाषा चुनें।';

  @override
  String get languageSystemDefault => 'सिस्टम डिफ़ॉल्ट';
}
